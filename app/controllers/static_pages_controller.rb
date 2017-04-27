class StaticPagesController < ApplicationController
  def index
    if signed_in?
      redirect_to nations_path
    else
      redirect_to new_user_session_path
    end
  end

  def no_access
  end
end
