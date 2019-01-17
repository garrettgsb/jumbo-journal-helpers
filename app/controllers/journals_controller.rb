class JournalsController < ApplicationController
  before_action :verify_logged_in
  def index
  end

  def create
    @journal = Journal.create(title: params[:journal][:title], user: @current_user)
    redirect_to "/users/#{@current_user.id}"
  end

  def new
    @journal = Journal.new(user: @current_user)
  end

  def show
    @journal = Journal.find(params[:id])
  end

  private

  def verify_logged_in
    redirect_to '/login' unless set_current_user
  end
end
