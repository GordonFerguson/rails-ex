class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  attr_accessor :current_user
  layout 'prc2b'

  # ##################################################
  # Authorization etc
  # ##################################################

  # return true iff the user is logged in with access to the given role
  # otherwise send them to the login page
  def test_access(required_role)
    authenticate_user
    if current_user.present?
      flash[:alert] = "You must be logged in access this pages."
      redirect_to home_page # aka the login page
    elsif ! current_user.role_allowed? required_role
      return true
    else
      flash[:alert] = "You do not have access to the #{required_role} pages."
      redirect_to home_page # todo: handle already logged in with insufficient access
    end
  end

  # Look up the user in the session
  def authenticate_user
    current_user.present? and current_user.role_allowed?(required_role)
  end

  # nb these routes are just test scaffolding,
  # they will be replaced with appropriate application pages
  # as they become available
  # todo : eval refactoring somehow: this is a smelly dependency
  def goto_role_home
    if current_user.present?
      case current_user.role
          when :visitor
          target_page = '/prc2b/visitor'
          when :data_entry
          target_page = '/prc2b/entry'
          when :editor
          target_page = '/prc2b/editor'
          when 'admin'
          target_page = '/prc2b/admin'
          else
          target_page = '/'
      end
    else
      target_page = '/';
    end
    redirect_to target_page
  end

  # lookup the current user based on data in the session object, if any
  # thanks: https://stackoverflow.com/questions/12719958/rails-where-does-the-infamous-current-user-come-from
  # @return User | nil
  def current_user
    return unless session[:user_id]
    @current_user ||= User.find(session[:user_id])
  end

  # Subclasses can limit access by overriding this method
  # @return Symbol
  def required_role
    :visitor
  end

  # Where to send under-authorized user?
  def home_page
    '/prcis'
  end

# ############################################
# other utilities
# ################################################
  #
  # trying this out
  def simple_xhr(partial)
    if request.xhr?
      respond_to do |format|
        format.html { render :partial => partial, :layout => false }
      end
    else
      'ERROR'
    end

  end

end
