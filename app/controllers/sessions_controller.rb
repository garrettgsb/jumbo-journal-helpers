class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token # Don't do this.

  def new
  end

  def create
    @user = User.find_by(name: params[:name])
    authenticated = @user && @user.authenticate(params[:password])
    if authenticated
      session[:user_id] = @user.id
      redirect_to "/users/#{@user.id}"
    else
      redirect_to '/login'
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to '/'
  end
end
