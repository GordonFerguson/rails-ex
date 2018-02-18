class PrcisController < ApplicationController
  before_action :authenticate_user, :except => [ :index, :login, :lookup_user]
  # layout 'edit'

  # the 'welcome page'
  #-- if not logged in: offer login; otherwise no content
  def index
    if current_user.present?
      goto_role_home
    else
      @user = User.new
      render :template => 'prcis/login'
    end
  end

  # the login action: see above and
  # I've configed devise to come here after a login failure too
  def login
    @user = User.new
    @user.login_id = params['id'] if params['id'] #todo why?
    render :template => 'prcis/login'
  end

  def logout
    session.delete(:user_id)
    goto_role_home # which is now the anonu home page
  end

  # this is the action for the login form
  # find the user, confirm the password, add user id to the session
  # redirect to the appropriate page [or reshow the login page]
  def lookup_user
    # fixme stub
    login_name = user_params['name']
    passwd = user_params['password']
    if @user = User.with_password(login_name, passwd)
      session[:user_id] = @user.id
      flash[:alert] = 'Login okay'
      # check for a existing target
      if user_params['target_path'].present?
        redirect_to user_params['target_path']
      else
        goto_role_home
      end
    else
      flash[:alert] = 'Login failed for '+login_name
      @user = User.new
      render :template => 'prcis/login'
    end
  end

private

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:name, :string, :password, :string, :salt, :string, :email, :string, :role, :string)
  end
end