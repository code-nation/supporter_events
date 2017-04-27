class EndpointsController < ApplicationController
  include NationsHelper, SyncHelper, EndpointsHelper, EventsHelper

  skip_before_action :verify_authenticity_token, :only => [:create_event]
  
  def create_event
    if params[:endpoint].present?
      nb_create_event(params[:endpoint])
      head :ok
    end
  end

end