class EventPage < ApplicationRecord

  # ==
  # Constants
  # ==
  STATUS_PENDING_SYNC = 1
  STATUS_SYNC_COMPLETE = 2
  STATUS_PENDING_DELETION = 3
  STATUS_DELETION_COMPLETE = 4

  # ==
  # Associations
  # ==
  belongs_to :site

  # ==
  # Validations
  # ==
  validates_presence_of :slug, :nb_event_page_id, :object, :status

  # ==
  # Methods
  # ==
  def original_url
    # Path already includes "/"
    "http://#{self.site.slug}-#{self.site.nation.slug}.nationbuilder.com#{self.object['path']}"
  end

  def slugify
    "#{self.slug}_#{self.site.nation.slug}_#{self.site.slug}_#{SecureRandom.urlsafe_base64(6).downcase}"
  end

end
