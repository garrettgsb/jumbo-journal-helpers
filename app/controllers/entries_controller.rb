class EntriesController < ApplicationController
  before_action :set_current_user
  before_action :verify_logged_in, except: [:show]
  before_action :set_entry, only: [:show, :edit, :update, :destroy]

  def new
    @entry = Entry.new
  end

  def create
    @entry = Entry.new(entry_params)
    @entry.journal_id = params[:journal_id]
    @entry.user = @current_user
    if @entry.save!
      redirect_to entry_path(@entry)
    else
      redirect_to journal_path
    end
  end

  def show
  end

  def edit
  end

  def update
    # Bail out early if this entry doesn't belong to the logged in user.
    return redirect_to login_path unless @entry && @entry.user == @current_user
    @entry.update(entry_params)
    redirect_to entry_path
  end

  def destroy
    # Bail out early if this entry doesn't belong to the logged in user.
    return redirect_to @current_user unless @entry && @entry.user == @current_user
    @entry.destroy!
    redirect_to @entry.journal
  end

  private

  def set_entry
    @entry = Entry.find(params[:id])
  end

  # To understand why we need to do this, read about "strong params."
  def entry_params
    params.require(:entry).permit(:title, :body)
  end

end
