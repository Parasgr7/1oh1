class Admin::UsersController < ApplicationController
  def index
    @users = User.all.sort_by_created_desc
    @users = @users.paginate(:page => params[:page], :per_page => 10)

  end
end
