class ChestsController < ApplicationController
  before_action :authenticate_user!
  def index
    @explore_amount = current_profile.wallet_histories.where(:source => "Explore").sum(:cost)
    @guide_amount = current_profile.wallet_histories.where(:source => "Guide").sum(:cost)
    @available_balance = !current_profile.wallet.nil? ? current_profile.wallet.coins : 100
    @wallet_history = current_profile.wallet_histories.order("created_at DESC")
    @guide_history = current_profile.wallet_histories.where("source LIKE ?","%Guide%").group("DATE_PART('month', updated_at)").sum(:cost)
    @explore_history = current_profile.wallet_histories.where("source LIKE ?","%Explore%").group("DATE_PART('month', updated_at)").sum(:cost)
    @bookings = current_profile.bookings
    @countries = @bookings.pluck(:guide_id).uniq
    @booking_id = params[:booking_id].present? ? params[:id] : nil
    @peer_user =  params[:peer_id].present? ? params[:peer_id] : nil
    @current_user_id = params[:profile_id].present? ? params[:profile_id] : nil
  end
end
