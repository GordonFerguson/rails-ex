=begin
Being refit from deon to prcis not quite done with that.
prcis uses summary and user management
=end
class AdminController < ApplicationController
  before_action :authenticate_user
  def required_role
    :admin
  end
  # layout 'edit'

  def index
    @title = 'Administration page'
    # @backup_npm = DatabaseBackupNpm.new
    # @data_review = DataReviewNpm.new
  end
=begin

  def compactness
    @title = 'Administration page'
    @backup_npm = DatabaseBackupNpm.new
    @data_review = DataReviewNpm.of_compactness
    if @data_review.compactness_okay?
      flash.notice = "Credit ordering data is consistent."
    else
      flash.alert = "ERROR: Credit ordering data is NOT consistent -- see details below."
    end
    render :index
  end

  def opening_dates
    @title = 'Administration page'
    @backup_npm = DatabaseBackupNpm.new
    @data_review = DataReviewNpm.of_opening_dates
    if @data_review.openings_report.empty?
      flash.notice = "Opening/closing dates data is consistent."
    else
      flash.alert = "ERROR: Credit Opening/closing dates data is NOT consistent -- see details below."
    end
    render :index
  end

  # GET /admin/backup
  # execute a backup, and redisplay the admin page with the revised list
  def backup
    @backup_npm = DatabaseBackupNpm.new
    status, file_name = @backup_npm.backup
    if status
      flash.notice = "Backup to #{file_name} completed."
    else
      flash.alert = "ERROR: Backup to #{file_name} failed."
    end
    redirect_to :action => :index
  end

  # download the specified file
  def dload
    fname = params[:name]+'.sql' # rails stole the xtension
    @backup_npm = DatabaseBackupNpm.new
    send_file(@backup_npm.path_to(fname), filename: fname)
  end


  # GET /admin/categories
  # manage credit categories, list all credits by category,
  # allow convenient editing of the category
  # TDDO figure out about remote vs reload on change
  def categories
    # @credits = Credit.category_grouping
    @credits = Credit.category_summary
  end

  def summary
    @grid = ProductionsGrid.new(params[:productions_grid]) do |scope|

      # Kaminari
      scope.page(params[:page]).per(1000)
      # WillPaginate
      # scope.page(params[:page]).per_page(10)
    end

    @grid.column(:title,{before: :note}) do |production|
      view_context.link_to production.title, view_context.edit_production_path(production), :target => '_blank'
    end

    @grid.production_count = 0
    @grid.column(:N) do |production|
      @grid.production_count += 1
    end
  end

  def new_user
    @title = 'Add a new user'
    @user = User.new
  end

  def create_user
    @user = User.new(new_user_params.merge({approved: true}))
    # @user.not_admin
    if @user.save
      flash[:alert] = "User has been created. "
    else
      flash[:alert] = "FAILED to save user. "+@user.errors.full_messages.join(', ')
    end
    redirect_to :action => :index
  end
=end

  def new_user_params
    params.require(:user).permit(:email, :password, :login_id, :role)
  end
end
