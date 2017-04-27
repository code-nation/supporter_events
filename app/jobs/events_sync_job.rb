class EventsSyncJob < ApplicationJob
  include SyncHelper
  queue_as :default

  after_perform do |job|
    record = job.arguments.first
    sync_all_pending_event_pages(record)
    delete_all_pending_event_pages(record)
  end

  def perform(nation)
	get_all_event_pages(nation)
  end
end