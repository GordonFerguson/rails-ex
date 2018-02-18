class Prc2bController < ApplicationController
  before_action :authenticate_user , :except => [ :index]
  def index
  end

  def visitor
  end

  def entry
  end

  def editor
  end

  def admin
  end

end
