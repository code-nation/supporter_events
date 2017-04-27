class AddIsAdminToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :is_admin, :boolean, default: false

    admin_emails = ENV['TECH_SUPPORT_EMAIL'].split(',').map{ |email| email.strip }
    admin_emails.each do |email|
      found_user = User.find_by(email: email)

      if found_user
        found_user.is_admin = true
        found_user.save
      else
        temp_password = 'unhackable'
        User.create(email: email, password: temp_password, password_confirmation: temp_password, is_admin: true)
      end
    end
  end
end
