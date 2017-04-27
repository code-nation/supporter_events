class Site < ApplicationRecord

  # ==
  # Associations
  # ==
  belongs_to :nation
  has_many :event_pages

  # ==
  # Validations
  # ==
  validates_presence_of :slug, :nb_site_id

  # ==
  # Methods
  # ==
  def has_event_page?(event_page_slug)
    has_event_page = false

    self.event_pages.each do |event_page|
      if event_page.slug.eql?(event_page_slug)
        has_event_page = true
        break
      end
    end

    has_event_page
  end

  def event_page_with_slug(event_page_slug)
    self.event_pages.where(slug: event_page_slug).first
  end

  def pending_sync_event_pages
    self.event_pages.where(status: EventPage::STATUS_PENDING_SYNC)
  end

  def pending_deletion_event_pages
    self.event_pages.where(status: EventPage::STATUS_PENDING_DELETION)
  end

  def update_slug_if_necessary(new_slug)
    unless self.slug.eql?(new_slug)
      self.slug = new_slug
      self.save
    end
  end

end
