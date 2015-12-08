class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update, :index, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only:  :destroy

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
      @user.send_activation_email
      flash[:info] = 'Please check your email to activate your account.'
      redirect_to root_url
    else
      flash.now[:danger] = 'Couldn\'t create a user.'
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

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = 'User deleted, you heartless.'
    redirect_to users_url
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

  def admin_user
    flash[:danger] = 'Nice try.' unless current_user.admin?
    redirect_to root_url unless current_user.admin?
  end
end
