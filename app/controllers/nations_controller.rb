class NationsController < ApplicationController
  load_and_authorize_resource
  include NationsHelper, SyncHelper

  before_action :set_nation, only: [:reconnect, :disconnect, :sync]
  before_action :authenticate_user!

  def index
    @nations = Nation.all
  end

  def new
    @nation = current_user.nations.build
  end

  def create
    @nation = current_user.nations.build(nation_params)

    if @nation.save
      cookies[:nation_id] = { value: @nation.id, expires: 10.minutes.from_now }
      redirect_to nb_authenticate_url
    else
      render :new
    end
  end

  def sync
    if current_user.is_admin? || @nation.user.is_approved
      begin
        get_all_sites @nation
        EventsSyncJob.perform_later(@nation.id)

        flash[:success] = 'Nation is successfully synchronizing. Please allow a few minutes for the process to complete.'
      rescue NationBuilder::BaseError => e
        flash[:error] = construct_error_message e
      ensure
        redirect_to nations_path
      end
    else
      flash[:error] = 'Only approved users can initiate the synchronization process.'
      redirect_to nations_path
    end
  end

  def disconnect
    @nation.token = nil
    if @nation.save
      flash[:warning] = 'Nation was successfully disconnected from NationBuilder.'
    else
      flash[:error] = 'Could not disconnect that nation from NationBuilder'
    end

    redirect_to nations_path
  end

  def reconnect
    cookies[:nation_id] = { value: @nation.id, expires: 10.minutes.from_now }
    redirect_to nb_authenticate_url
  end

  def oauth
    @nation = Nation.find(cookies[:nation_id])
    @nation.token = nb_get_token(params[:code])

    if @nation.save
      flash[:notice] = 'Nation was successfully connected to NationBuilder.'
      redirect_to nations_path
    else
      flash[:error] = 'Something went wrong. Please try again.'
      redirect_to nations_path
    end
  end

  private
  def set_nation
    @nation = Nation.find(params[:id])
  end

  def nation_params
    params.require(:nation).permit(:slug, :token)
  end

  def construct_error_message(exception)
    json_message = JSON.parse exception.message

    error_message = json_message['slug'] ? "For site slug: #{json_message['slug']} - #{json_message['message']}" : json_message['message']
    validation_messages = json_message['validation_errors'] ? "\"#{json_message['validation_errors'].join(', ')}\"" : ''

    "An unexpected error occurred. Please try again. (#{error_message} #{validation_messages})".strip
  end
end
