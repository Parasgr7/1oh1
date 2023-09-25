class MarketsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  before_action :set_market, only: [:show, :edit, :update, :destroy]

  # GET /markets
  # GET /markets.json
  def index
    @markets = Market.all
    @payments = Market.where(:mode => "Payment").sort_ascending
    @subscriptions = Market.where(:mode => "Subscription").sort_ascending
    if  profile_builder_complete[:profile_nil]
      flash[:notice] = 'Complete your profile first'
      redirect_to first_page_introduction_path
    elsif profile_builder_complete[:all_empty]
      flash[:notice] = 'Complete your Availability first'
      redirect_to availabilty_introduction_path
    else
      current_user.update(builder: true)
    end

  end

  # GET /markets/1
  # GET /markets/1.json
  def show
  end

  # GET /markets/new
  def new
    @market = Market.new
  end

  # GET /markets/1/edit
  def edit
  end

  # POST /markets
  # POST /markets.json
  def create
    @market = Market.new(market_params)
    respond_to do |format|
      if @market.save
        format.html { redirect_to @market, notice: 'Product was successfully created.' }
        format.json { render :show, status: :created, location: @market }
      else
        format.html { render :new }
        format.json { render json: @market.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /markets/1
  # PATCH/PUT /markets/1.json
  def update
    respond_to do |format|
      if @market.update(market_params)
        format.html { redirect_to @market, notice: 'Market was successfully updated.' }
        format.json { render :show, status: :ok, location: @market }
      else
        format.html { render :edit }
        format.json { render json: @market.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /markets/1
  # DELETE /markets/1.json
  def destroy
    Market.find(params[:id]).delete
    redirect_to products_path, notice: 'Product was successfully deleted.'

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_market
      @market = Market.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def market_params
      params.permit(:name,:offer,:interval,:mode,:price,:description,:currency,:order)
    end
end
