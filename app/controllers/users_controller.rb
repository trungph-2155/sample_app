class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy

  def index
    @users = User.paginate page: params[:page]
  end

  def show
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t "controllers.users.nonexist"
    redirect_to root_path
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    log_in @user
    if @user.save
      flash[:success] = t "controllers.users.welcome"
      log_in @user
      redirect_to @user
    else
      render :new
    end
  end

  def edit
    @user = User.find params[:id]
  end

  def update
    @user = User.find params[:id]
    if @user.update user_params
      flash[:success] = I18n.t "controllers.users.updated"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = I18n.t "controllers.users.deleted"
    redirect_to users_url
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation)
  end

  # Confirms a logged-in user.
  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = I18n.t "controllers.users.warning"
    redirect_to login_url
  end
end

# Confirms the correct user.
def correct_user
  @user = User.find params[:id]
  redirect_to root_url unless current_user?(@user)
end

# Confirms an admin user.
def admin_user
  redirect_to root_url unless current_user.admin?
end
