require 'nationbuilder'

module SyncHelper

  def get_all_sites(nation)
    client = nb_client(nation)
    response = client.call(:sites, :index, { limit: 100 })
    existing_sites_ids = []

    response['results'].each do |site|
      existing_sites_ids << site['id']
      current_site = nation.get_site site['id']

      if current_site
        current_site.update_slug_if_necessary site['slug']
      else
        nation.sites.create(slug: site['slug'], nb_site_id: site['id'])
      end
    end

    nation.delete_non_existing_sites existing_sites_ids
  end

  def get_all_event_pages(nation)
    nation = nation.kind_of?(Integer) ? Nation.find(nation) : nation
    client = nb_client(nation)
    sites = nation.sites

    sites.each do |site|
      params = {
          limit: 100,
          site_slug: site.slug
      }

      begin
        response = client.call(:events, :index, params)

        unless response['results'].empty?
          page = NationBuilder::Paginator.new(client, response)

          loop do
            page.body['results'].each do |event_page|
              if normalized_tags(event_page['tags']).include?(ENV['EVENT_PAGE_TAG']) && has_valid_status?(event_page['status']) # TODO: if status unlisted, expired, etc?
                if site.has_event_page?(event_page['slug'])
                  evaluate_status(site, event_page)
                else
                  site.event_pages.create(slug: event_page['slug'], nb_event_page_id: event_page['id'], object: event_page)
                end
              end
            end

            page = page.next
            break if page.nil?
          end
        end
      rescue NationBuilder::BaseError => e
        new_message = JSON.parse e.message
        new_message[:slug] = site.slug

        raise NationBuilder::BaseError.new(new_message.to_json)
      end
    end
  end

  def sync_all_pending_event_pages(nation)
    nation = nation.kind_of?(Integer) ? Nation.find(nation) : nation
    sites = nation.sites

    sites.each do |site|
      event_pages = site.pending_sync_event_pages
      client = primary_nation_nb_client

      event_pages.each do |event_page|
        params = {
            site_slug: ENV['PRIMARY_NATION_SITE_SLUG'],
            event: construct_event_hash(event_page)
        }

        response = client.call(:events, :create, params)

        if response
          event_page.status = EventPage::STATUS_SYNC_COMPLETE
          event_page.primary_nation_event_page_id = response['event']['id']
          event_page.save
        end
      end
    end
  end

  def delete_all_pending_event_pages(nation)
    nation = nation.kind_of?(Integer) ? Nation.find(nation) : nation
    sites = nation.sites

    sites.each do |site|
      event_pages = site.pending_deletion_event_pages
      client = primary_nation_nb_client

      event_pages.each do |event_page|
        params = {
            site_slug: ENV['PRIMARY_NATION_SITE_SLUG'],
            id: event_page.primary_nation_event_page_id
        }

        response = client.call(:events, :destroy, params)

        if response
          event_page.status = EventPage::STATUS_DELETION_COMPLETE
          event_page.save
        end
      end
    end
  end

  private
  def nb_client(nation)
    NationBuilder::Client.new(nation.slug, nation.token)
  end

  def primary_nation_nb_client
    NationBuilder::Client.new(ENV['PRIMARY_NATION_SLUG'], ENV['PRIMARY_NATION_API_TOKEN'])
  end

  def evaluate_status(site, event_page_response)
    event_page = site.event_page_with_slug(event_page_response['slug'])

    if normalized_tags(event_page_response['tags']).include?(ENV['EVENT_PAGE_DELETION_TAG']) && event_page.status != EventPage::STATUS_DELETION_COMPLETE
      event_page.status = EventPage::STATUS_PENDING_DELETION
      event_page.save
    end
  end

  def normalized_tags(tags)
    normalized_tags = []

    tags.each do |tag|
      normalized_tags.push(normalize_tag(tag))
    end

    normalized_tags
  end

  def has_valid_status?(event_page_status)
    valid_statuses = ENV['VALID_EVENT_PAGE_STATUSES'].split(',').collect { |status| normalize_tag(status) } # normalized statuses
    valid_statuses.include?(normalize_tag(event_page_status))
  end

  # This will map the existing event data and build the necessary JSON format
  # See all event options here: http://nationbuilder.com/event_resource
  def construct_event_hash(event_page)
    {
      calendar_id: ENV['PRIMARY_NATION_CALENDAR_ID'].to_i,
      # Optionally set the status to 'unlisted' to facilitate an approval process
      status: 'published',
      # Optionally restrict which tags are cloned
      tags: all_event_tags(event_page),
      name: event_page.object['name'],
      headline: event_page.object['headline'],
      # Optionally set the title and slug values below (we are
      # currently letting NationBuilder set them automatically)
      # title: event_page.object['title'],
      # slug: event_page.slugify,
      excerpt: event_page.object['excerpt'],
      # Optionally uncomment the excerpt line below, delete the excerpt line above and
      # change {{ event.url }} to {{ event.excerpt }} in your theme's calendar template.
      # That way, you can redirect users to the original event URL when they click the
      # RSVP button on your calendar page.
      # excerpt: event_page.original_url,
      intro: event_page.object['intro'],
      # The event_contact method only adds the contact if name and email exist:
      # this is a restriction imposed by the NationBuilder API
      contact: event_contact(event_page),
      start_time: event_page.object['start_time'],
      end_time: event_page.object['end_time'],
      venue: event_page.object['venue'],
      capacity: event_page.object['capacity'],
      published_at: event_page.object['published_at'],
      # Choose appropriate rsvp_form settings or clone their original values
      # rsvp_form: event_page.object['rsvp_form'],
      rsvp_form: {
          phone: 'hidden',
          address: 'hidden',
          allow_guests: false,
          accept_rsvps: false,
          gather_volunteers: false
      },
      # Optionally set values for the `autoresponse` and `shifts` attributes
      # autoresponse: event_page.object['autoresponse'],
      # shifts: event_page.object['shifts'],
      show_guests: event_page.object['show_guests']
    }
  end

  # This will join the tags from the SYNC_EVENT_TAGS
  # environment variable with the original event tags
  def all_event_tags(event_page)
    tags = ENV['SYNC_EVENT_TAGS'].split(',').map{ |tag| tag.strip } << event_page.object['tags']
    tags.flatten
  end

  def normalize_tag(tag)
    tag.strip.downcase.gsub(/ /, '_').gsub(/-/, '_')
  end

  def event_contact(event_page)
    if event_page.object['contact']['name'] && event_page.object['contact']['email'] &&
        !event_page.object['contact']['name'].blank? && !event_page.object['contact']['email'].blank?
      event_page.object['contact']
    else
      nil
    end
  end
end