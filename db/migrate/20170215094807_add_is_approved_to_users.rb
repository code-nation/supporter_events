class AddIsApprovedToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :is_approved, :boolean, default: false

    users = User.all
    users.each do |user|
      if user.is_admin
      	user.is_approved = true
      	user.save
      end
    end
  end
end
