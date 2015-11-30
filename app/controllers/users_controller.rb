class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update, :index]
  before_action :correct_user,   only: [:edit, :update]

  def index
    @users = User.paginate page: params[:page], per_page: 15
  end

  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = 'Hard to believe but it actually worked.'
      redirect_to @user
    else
      flash.now[:danger] = 'Error.'
      render :new
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = 'Hard to believe but it actually worked.'
      redirect_to @user
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation)
  end

  # BEFORE FILTERS

  def logged_in_user
    return if logged_in?
    store_location
    flash[:danger] = 'Please log in to proceed.'
    redirect_to login_url
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to root_url unless current_user? @user
  end
end
