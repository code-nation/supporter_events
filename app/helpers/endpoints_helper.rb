module EndpointsHelper

  # This will add the event creator to NationBuilder
  # (or update their profile if it already exists)
  def nb_add_signup(data)
		client = primary_nation_nb_client
		params = { person: data[:person].as_json }
    response = client.call(:people, :add, params)
  end

  # This will create the event in NationBuilder
  def nb_create_event(data)
		signup_data = nb_add_signup(data)
		event_params = build_event_params(data, signup_data['person']['id'])
		client = primary_nation_nb_client
    params = {
      site_slug: ENV['PRIMARY_NATION_SITE_SLUG'],
      event: event_params
    }

		begin
	    response = client.call(:events, :create, params)

	    if response['status_code'] == 200
	    	NotificationsMailer.event_created(signup_data, response['event']).deliver_now

	    	# if a webhook URL is provided, the new event data is sent to that URL
	    	unless ENV['NEW_EVENT_WEBHOOK_URL'].nil? && ENV['NEW_EVENT_WEBHOOK_URL'].blank?
	    		send_data_to_external_service(ENV['NEW_EVENT_WEBHOOK_URL'], response['event'])
	    	end

	    	admins = User.admin_receive_notifications
	    	admins.each do |admin|
	    		AdminNotificationsMailer.event_created(admin.email, signup_data, response['event']).deliver_now
	    	end
	    end
		rescue => e
		  SupportNotificationsMailer.error_handler(event_params, JSON.parse(e.message)).deliver_now
		end
  end

  private

  	# This will map the data from the create_event form and build the JSON format
    # See all event options here: http://nationbuilder.com/event_resource
  	def build_event_params(data, author_id)
	    {
        calendar_id: ENV['PRIMARY_NATION_CALENDAR_ID'].to_i,
	      # Status is set to 'unlisted' to facilitate an approval process
        status: "unlisted",
	      # Optionally restrict which tags are created
        tags: build_tags(ENV['CREATE_EVENT_ENDPOINT_TAGS'], data[:event][:tags]),
        name: data[:event][:event_name],
        excerpt: data[:event][:event_excerpt],
        author_id: author_id,
        intro: data[:event][:event_content],
        # The build_event_contact method only adds the contact if name and email exist:
        # this is a restriction imposed by the NationBuilder API
        contact: build_event_contact(data),
        start_time: data[:event][:start_time],
        end_time: data[:event][:end_time],
        venue: {
          name: data[:event][:venue_name],
          address: {
            address1: data[:event][:street],
            city: data[:event][:suburb],
            state: data[:event][:state],
            zip: data[:event][:postcode]
          }
        },
        # A capacity value of 0 creates the event with an unlimited capacity
        capacity: 0,
        # Choose appropriate rsvp_form settings below
        rsvp_form: {
          phone: "hidden",
          address: "hidden",
          allow_guests: true,
          accept_rsvps: true,
          gather_volunteers: false
        },
        # Optionally set values for the `autoresponse` and `shifts` attributes
        show_guests: true
	    }
  	end

  	# This will join the tags from the CREATE_EVENT_ENDPOINT_TAGS
  	# environment variable with the tags from the create_event form
  	def build_tags(tags, category)
  		tags = tags.split(',').map{ |tag| tag.strip } << category
  		tags.flatten
  	end

  	# This method will build the event contact information
    # It ensures we only add the contact if name and email exist,
    # which is a restriction imposed by the NationBuilder API
		def build_event_contact(data)
			contact_full_name = "#{data[:person][:first_name]} #{data[:person][:last_name]}"
			if contact_full_name.nil? || contact_full_name.blank? || data[:person][:email].nil? || data[:person][:email].blank?
				nil
			else
      	{
          name: contact_full_name,
          mobile: data[:person][:mobile],
          show_phone: true,
          email: data[:person][:email].strip,
          show_email: true
        }
		end
	end

	# An optional environment variable - send new event data to an external service
	# For example, send it to a Zapier catch hook in order to use the new event data
	# in a separate app (e.g. to create a notification in Slack)
	def send_data_to_external_service(url, data)
    connect = Faraday.new(:url => url)
    connect.post do |request|
      request.headers['Content-Type'] = 'application/json'
      request.body = data.to_json
    end
  end
end
