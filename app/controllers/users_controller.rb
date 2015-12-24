class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update, :index, :destroy,
                                        :following, :followers]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only:  :destroy

  def index
    @users = User.where(activated: true).paginate page: params[:page], per_page: 15
  end

  def new
    if logged_in?
      flash[:info] = 'You are already logged in, there\'s no need for that.'
      redirect_to root_url
    end
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
    redirect_to root_url and return unless @user.activated?
    @microposts = @user.microposts.paginate(page: params[:page], per_page: 15)
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

  def following
    @title = 'Following'
    @user  = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = 'Followers'
    @user  = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation)
  end

  # BEFORE FILTERS

  def correct_user
    @user = User.find(params[:id])
    redirect_to root_url unless current_user? @user
  end

  def admin_user
    return if current_user.admin?
    flash[:danger] = 'Nice try.'
    redirect_to root_url
  end
end
