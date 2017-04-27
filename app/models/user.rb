class User < ApplicationRecord

  devise :invitable, :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable

  # ==
  # Associations
  # ==
  has_many :nations, dependent: :nullify

  # ==
  # Methods
  # ==
  def self.admin_users
    where(is_admin: true)
  end

  def self.users
    where(is_admin: false)
  end

  def self.admin_receive_notifications
    self.admin_users.where(receive_notifications: true)
  end
end
