class AddReceiveNotificationsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :receive_notifications, :boolean, default: true
  end
end
