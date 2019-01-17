class ApplicationController < ActionController::Base
  before_action :set_current_user

  def home
    render :home
  end

  private

  def set_current_user
    @current_user = session[:user_id] && User.find(session[:user_id])
  end

  def verify_logged_in
    redirect_to '/login' unless set_current_user
  end
end
