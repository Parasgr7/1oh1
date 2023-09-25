class SubscribesController < ApplicationController
  before_action :set_subscribe, only: [:show, :edit, :update, :destroy]

  # GET /subscribes
  # GET /subscribes.json
  def index
    @subscribes = Subscribe.all
    @subscribe = Subscribe.new
  end

  # GET /subscribes/1
  # GET /subscribes/1.json
  def show
  end

  # GET /subscribes/new
  def new
    @subscribe = Subscribe.new
  end

  # GET /subscribes/1/edit
  def edit
  end

  # POST /subscribes
  # POST /subscribes.json
  def create
    @subscribe = Subscribe.new({email: params[:email]})
    respond_to do |format|
      if @subscribe.save
        if params[:footer]=="true"
          flash.now[:success] = "Subscribed to newsletter!!"
          @flashing = flash
          format.js
        else
          format.html { redirect_to root_path, notice: 'Subscribe was successfully created.' }
        end
      else
        format.html { render :new }
        format.json { render json: @subscribe.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /subscribes/1
  # PATCH/PUT /subscribes/1.json
  def update
    respond_to do |format|
      if @subscribe.update(subscribe_params)
        format.html { redirect_to @subscribe, notice: 'Subscribe was successfully updated.' }
        format.json { render :show, status: :ok, location: @subscribe }
      else
        format.html { render :edit }
        format.json { render json: @subscribe.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /subscribes/1
  # DELETE /subscribes/1.json
  def destroy
    @subscribe.destroy
    respond_to do |format|
      format.html { redirect_to subscribes_url, notice: 'Subscribe was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_subscribe
      @subscribe = Subscribe.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def subscribe_params
      params.fetch(:subscribe, {})
    end
end
