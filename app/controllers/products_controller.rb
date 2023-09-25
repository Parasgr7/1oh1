class ProductsController < ApplicationController
  before_action :authenticate_user!
  def index
    @products = Market.all.sort_ascending
    @product = Market.new
    authorize! :admin, @products
  end

  def new
  end

  def create
  end

  def update
  end

  def destroy
  end

end
