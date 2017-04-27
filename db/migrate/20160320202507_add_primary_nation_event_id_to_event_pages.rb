class AddPrimaryNationEventIdToEventPages < ActiveRecord::Migration[5.0]
  def change
    add_column :event_pages, :primary_nation_event_page_id, :integer
  end
end
