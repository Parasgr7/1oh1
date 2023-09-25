require 'rest-client'
require 'stripe'
require 'json'
class PaymentController < ApplicationController
  rescue_from Stripe::CardError, with: :catch_exception

  def index
    session_id = params["session_id"]
    if !session_id.nil?
    Stripe.api_key = 'sk_test_RtD0URFi6IkU7cdGsNms5TKj00lRyT23Gv'

     data = JSON(Stripe::Checkout::Session.retrieve(session_id))
     type = JSON.parse(data)["display_items"][0]["type"]
     product_id = JSON.parse(data)["display_items"][0]["#{type}"]["id"]

     if !current_user.nil?
       if current_user.profile.transactions.last.market.stripe_id == product_id
         render json: {data: Stripe::Checkout::Session.retrieve(session_id)}
       end
     else
       render json: {data: "Invalid User"}
     end
   else
     render 'errors/not_found'
   end
  end

  def new
  end

  def canceled
  end

  def create
    StripeChargesServices.new(charges_params, current_user).call
    redirect_to payment_index_path
  end

  def after_payment
    payload = request.body.read
    event = nil
    endpoint_secret = 'whsec_vLuVS2mxwPnsWFX3VklaUOHql4uvgm4k'

    # Verify webhook signature and extract the event
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError => e
      # Invalid payload
      render json: {status: 400}
    return
    rescue Stripe::SignatureVerificationError => e
      # Invalid signature
      render json: {status: 400}
      return
    end


    if event['type'] == 'checkout.session.completed'
      session = event['data']['object']
      # Fulfill the purchase...
      handle_checkout_session(session)
    end
    render json: {status: 200}
  end

  private

  def handle_checkout_session(session)
    transaction = Transaction.new

    transaction.customer_id = session["customer"]
    transaction.currency = session["display_items"][0]["currency"]
    transaction.price = session["display_items"][0]["amount"]
    current_profile = User.find_by_email(session["customer_email"]).profile
    transaction.profile = current_profile
    transaction.mode = session["mode"]

    if transaction.mode == "payment"
      transaction.name = session["display_items"][0]["sku"]["attributes"]["name"]
      transaction.interval = nil
      transaction.product_id = session["display_items"][0]["sku"]["product"]
      mode_id = session["display_items"][0]["sku"]["id"]
    elsif transaction.mode == "subscription"
      transaction.name = session["display_items"][0]["plan"]["nickname"]
      transaction.interval = session["display_items"][0]["plan"]["interval"]
      transaction.product_id = session["display_items"][0]["plan"]["product"]
      mode_id = session["display_items"][0]["plan"]["id"]

    end

    transaction.market = Market.find_by_stripe_id(mode_id)

    body = RestClient::Request.execute( method: "get",url: 'https://api.stripe.com/v1/charges',
            user: 'sk_test_RtD0URFi6IkU7cdGsNms5TKj00lRyT23Gv',
            headers: {customer: transaction.customer_id}
          )
    response = JSON.parse(body)

    transaction.charge_id = response["data"][0]["id"]

    if transaction.save
      self_wallet = Wallet.find_by(profile_id: current_profile.id)
      #Update wallet_history and wallet coins for Self, source: Transaction
      self_history = WalletHistory.create(wallet_id: self_wallet.id, cost:   transaction.market.coins, prev_bal: self_wallet.coins, new_bal: self_wallet.coins +   transaction.market.coins,action: transaction,source: "Purchase")
      self_wallet.update(coins: self_history.new_bal)
    end

  end

  def charges_params
    params.permit(:stripeEmail, :stripeToken, :order_id)
  end

  def catch_exception(exception)
    flash[:error] = exception.message
  end

end
