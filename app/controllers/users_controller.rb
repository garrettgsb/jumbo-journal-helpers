class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token # Don't do this.

  def index
    @users = User.all
    render :index
  end

  def show
    @user = User.find(params[:id])
    @journals = @user.journals
    render :show
  end

  def new
    @user = User.new
    render :new
  end

  def create
    @user = User.create name: params[:name], password: params[:password]
    redirect_to "/users/#{@user.id}"
  end
end
