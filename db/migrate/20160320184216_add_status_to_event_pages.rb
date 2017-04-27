class AddStatusToEventPages < ActiveRecord::Migration[5.0]
  def change
    add_column :event_pages, :status, :smallint, default: EventPage::STATUS_PENDING_SYNC
  end
end
