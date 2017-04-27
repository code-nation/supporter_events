class UsersController < ApplicationController
  before_action :authenticate_admin_user!, except: [:request_access, :join]
  before_action :set_user, only: [:destroy, :approve, :make_admin, :receive_notification]

  def index
    @users = User.users
  end

  def admins
    @users = User.admin_users
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    @user.is_admin = true
    @user.password = SecureRandom.base64 8
    @user.password_confirmation = @user.password

    if @user.save
      AdministratorInvitation.invite(@user.email, @user.password).deliver_now

      flash[:success] = 'User was successfully invited.'
      redirect_to users_path
    else
      render :new
    end
  end

  def destroy
    nations = @user.nations.map {|nation| nation.slug}
    if @user.destroy
      nations.each do |nation|
        nation = Nation.find_by_slug(nation)
        nation.user_id = current_user.id
        nation.save
      end
      flash[:info] = 'User was successfully deleted.'
    else
      flash[:error] = 'User could not be deleted. Please try again.'
    end

    redirect_to users_path
  end

  def approve
    @user.is_approved = true
    @user.save

    if params[:code].present?
      AccessRequestsMailer.approved(@user.email, params[:code]).deliver_now
    end

    flash[:info] = "#{@user.email} was successfully approved."
    redirect_to users_path
  end

  def make_admin
    @user.is_admin = true
    @user.save

    flash[:info] = "#{@user.email} is now an admin."
    redirect_to users_path
  end

  def request_access
  end

  def join
    @user = User.new(email: params[:email])

    @user.password = SecureRandom.base64 8
    @user.password_confirmation = @user.password

    if @user.save
      admins = User.admin_receive_notifications
      admins.each do |admin|
        AccessRequestsMailer.approval(admin.email, @user.email, @user.password).deliver_now
      end
      flash[:success] = 'Your request was successfully sent for approval.'
    else
      flash[:success] = 'You have already requested access. Please wait for an admin to approve your request.'
    end
    redirect_to request_access_users_path
  end

  def receive_notification
    @user.update(user_params)
  end

  private
  def user_params
    params.require(:user).permit(:email, :is_approved, :receive_notifications)
  end

  def set_user
    @user = User.find(params[:id])
  end

  def authenticate_admin_user!
    unless authenticate_user! && current_user.is_admin?
      flash[:error] = 'Access forbidden.'
      redirect_to root_path
    end
  end
end
