require 'securerandom'
include IceCube
class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_booking, only: [:show, :edit, :update, :destroy]
  before_action :set_booking_status, only: :index
  helper_method :sort_column, :sort_direction

  # GET /bookings
  # GET /bookings.json
  def index
    if params["self"].to_i == 1 && params["other"].to_i == 1

      if params["explore_id"] !=nil
        @reservation_bookings = (Explore.find(params["explore_id"].to_i).profile.bookings + Profile.find(current_profile_id).bookings).uniq
        all_other_user_ids = Explore.find(params["explore_id"].to_i).profile.bookings.map(&:id)
        all_current_user_ids = current_user.profile.bookings.pluck(:id).uniq
        @meta = {other: all_other_user_ids, self: all_current_user_ids, common: all_other_user_ids & all_current_user_ids }
      elsif params["guide_id"] !=nil
        @reservation_bookings = (Guide.find(params["guide_id"].to_i).profile.bookings + Profile.find(current_profile_id).bookings).uniq
        all_other_user_ids = Guide.find(params["guide_id"].to_i).profile.bookings.map(&:id)
        all_current_user_ids = current_user.profile.bookings.pluck(:id).uniq
        @meta = {other: all_other_user_ids, self: all_current_user_ids, common: all_other_user_ids & all_current_user_ids }
      end

    elsif params["self"].to_i == 1 && params["other"].to_i == 0
      @reservation_bookings = current_user.profile.bookings.includes(:explore,:guide).where(flag: false).uniq
      availabilities = current_profile.availabilities.nil? ? [] :  current_profile.availabilities
      if current_profile.availabilities.nil?
        @unavailabilities = []
        @availabilities = []
      else
        @unavailabilities = unavialabilities(current_profile.availabilities)
        @availabilities = ["assas"]
      end

    elsif params["self"].to_i == 0 && params["other"].to_i == 1

      if params["explore_id"] != nil
        @reservation_bookings = Explore.find(params["explore_id"].to_i).profile.bookings.uniq
      elsif params["guide_id"] !=nil
        @reservation_bookings = Guide.find(params["guide_id"].to_i).profile.bookings.uniq
      end

    else
      @reservation_bookings=[]
    end

    @profile_id = current_profile.id
    @schedule_time = current_profile.personal_setting.nil? ? 0.minutes : current_profile.personal_setting.schedule_time
    @bookings = current_profile.bookings.includes(explore: [ profile: :user], guide: [ :category,profile: :user])
    @pending_bookings =  @bookings.where(:status => 0,flag: false).where.not(client_id: @profile_id).order(sort_column + " " + sort_direction).uniq
    @submitted_bookings =  @bookings.where(:status => 0,client_id: @profile_id,flag: false).order(sort_column + " " + sort_direction).uniq
    @upcoming_bookings = @bookings.where(:status => 1,flag: false).order(sort_column + " " + sort_direction).uniq
    @completed_bookings = @bookings.where(:status => 2,flag: true).order(sort_column + " " + sort_direction).uniq

    @bookings = Profile.find_by_id(current_user.profile.id).bookings.uniq
  end

  # GET /bookings/new
  def new
    @booking = Booking.new
  end

  # GET /bookings/1/edit
  def edit
    @booking = Booking.find(params[:id])
    @balance = !current_profile.wallet.coins.nil? ? current_profile.wallet.coins : 100

  end

  # POST /bookings
  # POST /bookings.json
  def create
    @booking = Booking.new(booking_params)
    @booking.start = Time.zone.parse(params[:booking][:start]).getutc
    @booking.end =  Time.zone.parse(params[:booking][:end]).getutc
    @diff_seconds = (params[:booking][:end].to_time-params[:booking][:start].to_time).to_i
    @booking.duration = format_time(@diff_seconds)
    if params["status"] == "3" #unaviable events for personal calendar
      @booking.guide_id = Guide.first.id
      @booking.explore_id = Explore.first.id
      @booking.client_id = current_profile_id
      @booking.recipient_id = current_profile.id
      @booking.identifier = SecureRandom.base64(10)
      @booking.status = params["status"].to_i
      if @booking.save
        @booking.video_sessions.create(profile_id: current_user.profile.id)
        redirect_to calendars_path
      end
    end
  end

  def show
    @end = @booking.end
    @time_left = @booking.start - Time.current
    if @booking.guide.profile.id == current_user.profile.id
      @my_role = "Guide"
      @user = @booking.guide.profile.user
      @companion = @booking.explore.profile.user
    else
      @my_role = "Explorer"
      @user = @booking.explore.profile.user
      @companion = @booking.guide.profile.user
    end
    if @end < Time.zone.now
      render 'errors/internal_error'
    end
  end

  # PATCH/PUT /bookings/1
  # PATCH/PUT /bookings/1.json
  def update
    @profile_id = current_profile.id
    if params[:approve_request] == "true" && params[:change_request].nil? #for Approving request from Pending State by Guide
      @booking = Booking.find(params[:id])
      @booking.update(:status => 1)
      flash.now[:success] = "Booking Approved!"
      @new_bookings = current_profile.bookings.includes(explore: [ profile: :user], guide: [ :profile,:category])
      @upcoming_bookings = @new_bookings.where(:status => 1,flag: false).sort_descending.uniq
      @pending_bookings =  @new_bookings.where(:status => 0,flag: false).where.not(client_id: @profile_id).sort_descending.uniq
      @submitted_bookings =  @new_bookings.where(:status => 0,client_id: @profile_id,flag: false).sort_descending.uniq

      UserMailer.booking_request_approved_guide(@booking).deliver_later #recipient
      UserMailer.booking_request_approved_explore(@booking).deliver_later #client

      #update guide wallet add +coins and update wallet_history

      @guide_wallet = Wallet.find_by(profile_id: current_user.profile.id)
      @guide_history = WalletHistory.create(
                                    wallet_id: @guide_wallet.id,
                                    cost: @booking.coins,
                                    prev_bal: @guide_wallet.coins,
                                    new_bal: @guide_wallet.coins + @booking.coins,
                                    action: @booking,
                                    source: "Guide")

      @guide_wallet.update(coins: @guide_history.new_bal)


      @flashing = flash
      respond_to do |format|
        format.js
      end
    elsif params[:approve_request].nil? && eval(params["payload"])["edit"] == "true"  #for Changing request from Upcoming state to Pending
      booking_params = set_create_booking(eval(params["payload"]))
      @booking = Booking.find(params[:id])
      @other_profile_id = @booking.profile_ids.select{|x| x!= current_profile_id}[0]
      booking_start =  Time.zone.parse((booking_params[:date] +" "+ booking_params[:start_time])).getutc
      booking_end =  Time.zone.parse((booking_params[:date] +" "+ booking_params[:end_time])).getutc

      @booking.update_columns(:status => "pending",:client_id=>current_profile_id,:recipient_id=>@other_profile_id,start: booking_start, end: booking_end)

      flash[:success] = "Booking Change Requested!"
      redirect_to booking_completed_path

    end
  end

  # DELETE /bookings/1
  # DELETE /bookings/1.json
  def destroy
    if !params[:booking_id].nil?
      @booking = Booking.find(params[:booking_id])
      @action = params[:action_as]
      puts Time.zone.now
      puts @booking.start
      puts (Time.zone.now - @booking.start.to_datetime.in_time_zone(current_profile.time_zone)).to_i.abs
        if @booking.guide.profile_id == current_profile_id
          @type = "Guiding" ############ booking decline by Guide ################
          @companion = @booking.explore

          if @booking.status == "pending" #booking declined from pending & submitted state
            @explorer_wallet = Wallet.find_by(profile_id: @companion.profile.id)
            @explorer_history = WalletHistory.create(
                                            wallet_id: @explorer_wallet.id,
                                            cost: @booking.coins,
                                            prev_bal: @explorer_wallet.coins,
                                            new_bal: @explorer_wallet.coins + @booking.coins,
                                            action: @booking,
                                            source: "Cancelled by Guide")
            @explorer_wallet.update(coins: @explorer_history.new_bal)

          elsif @booking.status == "upcoming" # canceled from upcoming state by guide with extra charge
            # G(-) & E (+)
            extra_fee_detail = cancellation_fee_calculator(Time.zone.now,@booking,current_profile.time_zone)

            @guide_wallet = Wallet.find_by(profile_id: @booking.guide.profile_id)
            @explorer_wallet = Wallet.find_by(profile_id: @booking.explore.profile_id)

            @guide_history = WalletHistory.create(
                                          wallet_id: @guide_wallet.id,
                                          cost: -(@booking.coins + extra_fee_detail[:total_fee]),
                                          prev_bal: @guide_wallet.coins,
                                          new_bal: @guide_wallet.coins - @booking.coins - extra_fee_detail[:total_fee],
                                          action: @booking,
                                          source: "Cancelled by Guide")

            @guide_wallet.update(coins: @guide_history.new_bal)

            @explorer_history = WalletHistory.create(
                                            wallet_id: @explorer_wallet.id,
                                            cost: @booking.coins,
                                            prev_bal: @explorer_wallet.coins,
                                            new_bal: @explorer_wallet.coins + @booking.coins,
                                            action: @booking,
                                            source: "Cancelled by Guide")
            @explorer_wallet.update(coins: @explorer_history.new_bal)

          end


        else
          @type = "Exploring" ############## booking declined by Explorer ##############
          @companion = @booking.guide
          if @booking.status == "pending" #booking declined from pending & submitted state
            @explorer_wallet = Wallet.find_by(profile_id: @booking.explore.profile.id)
            @explorer_history = WalletHistory.create(
                                            wallet_id: @explorer_wallet.id,
                                            cost: @booking.coins,
                                            prev_bal: @explorer_wallet.coins,
                                            new_bal: @explorer_wallet.coins + @booking.coins,
                                            action: @booking,
                                            source: "Cancelled by Explorer")

              @explorer_wallet.update(coins: @explorer_history.new_bal)

          elsif @booking.status == "upcoming"   # canceled from upcoming state by explorer with extra charge
            # E (-) & G(+)
            extra_fee_detail = cancellation_fee_calculator(Time.zone.now,@booking,current_profile.time_zone)

            @guide_wallet = Wallet.find_by(profile_id: @booking.guide.profile_id)
            @explorer_wallet = Wallet.find_by(profile_id: @booking.explore.profile_id)

            @guide_history = WalletHistory.create(
                                          wallet_id: @guide_wallet.id,
                                          cost: -@booking.coins,
                                          prev_bal: @guide_wallet.coins,
                                          new_bal: @guide_wallet.coins - @booking.coins,
                                          action: @booking,
                                          source: "Cancelled by Explorer")

            @guide_wallet.update(coins: @guide_history.new_bal)

            @explorer_history = WalletHistory.create(
                                            wallet_id: @explorer_wallet.id,
                                            cost: (@booking.coins - extra_fee_detail[:total_fee]),
                                            prev_bal: @explorer_wallet.coins,
                                            new_bal: @explorer_wallet.coins + @booking.coins - extra_fee_detail[:total_fee],
                                            action: @booking,
                                            source: "Cancelled by Explorer")

            @explorer_wallet.update(coins: @explorer_history.new_bal)

          end
        end





      if @booking.update_attributes({flag: true, status: 2})


        UserMailer.booking_request_declined_guide(@booking,current_user,@companion.profile.user).deliver_later #guide
        UserMailer.booking_request_declined_explore(@booking,@companion.profile.user,current_user).deliver_later #client

        @profile_id = current_profile.id
        flash.now[:success] = "Booking Deleted!"
        @flashing = flash
        @bookings = current_profile.bookings.includes(explore: [ profile: :user], guide: [ :profile,:category])
        @pending_bookings =  @bookings.where(:status => 0,flag: false).where.not(client_id: @profile_id).sort_descending.uniq
        @upcoming_bookings = @bookings.where(:status => 1,flag: false).order(created_at: :desc).uniq
        @submitted_bookings =  @bookings.where(:status => 0,client_id: @profile_id,flag: false).sort_descending.uniq

        Notification.create(recipient: @companion.profile.user, user: current_user, action: "declined", notifiable: current_user, url: "/bookings" )
      end

      respond_to do |format|
        format.js
      end
    end
  end

  def time_slots
    @slot_timing = params[:slot]
    profile_id = params[:profile]
    @front_end_time_zone = params[:time_zone]
    @date = params[:date]
    @timeZone = Timezone[Profile.find_by_id(profile_id).time_zone]
    timezone = Timezone[Profile.find_by_id(profile_id).time_zone]
    @schedule_time = Profile.find_by_id(profile_id).personal_setting.nil? ? 0.minutes : Profile.find_by_id(profile_id).personal_setting.schedule_time.nil? ? 30.minutes : Profile.find_by_id(profile_id).personal_setting.schedule_time
    @buffer_time = Profile.find_by_id(profile_id).personal_setting.nil? ? 0.minutes : Profile.find_by_id(profile_id).personal_setting.buffer_time.nil? ? 0.minutes : Profile.find_by_id(profile_id).personal_setting.buffer_time
    day_of_week_hash = Date::DAYNAMES.map.with_index{ |x, i| [i, x] }.to_h

    @available_times = Profile.find_by_id(profile_id).availabilities.find_by(week_day: @date.to_datetime.in_time_zone(timezone.name).wday)

    @off_days = Profile.find_by_id(profile_id).availabilities.where(full_day_off: true).pluck(:week_day).map{|x| day_of_week_hash[x]}
    if !@available_times.nil?

      if @available_times.full_day_off
        @schedule = IceCube::Schedule.new(start =(@date+" " + "9 AM".to_time.strftime("%H:%M")).in_time_zone(timezone.name)) do |s|
          s.add_recurrence_rule IceCube::Rule.minutely(@slot_timing)
        end
        @slots=@schedule.occurrences((@date+" " + "5 PM".to_time.strftime("%H:%M")).in_time_zone(timezone.name))
      else
        @schedule = IceCube::Schedule.new(start = (@date+" " + @available_times.start_time.strftime("%H:%M")).in_time_zone(timezone.name)) do |s|
          s.add_recurrence_rule IceCube::Rule.minutely(@slot_timing)
        end
        @slots=@schedule.occurrences((@date+" " + @available_times.end_time.strftime("%H:%M")).in_time_zone(timezone.name))
      end

      #code for unavailabilities multiple
      if @available_times[:timing].present?
        @available_times[:timing].each do |time|
          @range_first = (@date+" " +time[0]).in_time_zone(timezone.name)..(@date+" " +time[1]).in_time_zone(timezone.name)
          @slots.select!{|x| !@range_first.include?(x)}
        end
      end

    else
      @schedule = IceCube::Schedule.new(start = (@date+" " + "9 AM".to_time.strftime("%H:%M")).in_time_zone(timezone.name)) do |s|
        s.add_recurrence_rule IceCube::Rule.minutely(@slot_timing)
      end
      @slots=@schedule.occurrences((@date+" " + "5 PM".to_time.strftime("%H:%M")).in_time_zone(timezone.name))

    end
    booking_unavailabile = Profile.find_by_id(profile_id).bookings.where(start: (@date).to_datetime.in_time_zone("UTC").beginning_of_day..(@date).to_datetime.in_time_zone("UTC").end_of_day)
    @arr=[]
    if !booking_unavailabile.empty?
      booking_unavailabile.each do |unavailable|
        if unavailable.status != "unavailable"
          a = (unavailable[:start]).to_datetime.in_time_zone(timezone.name)
          b = (unavailable[:end]).to_datetime.in_time_zone(timezone.name)
          @range_second = (unavailable[:start]).to_datetime.in_time_zone(timezone.name)..(unavailable[:end]+ @buffer_time.minutes).to_datetime.in_time_zone(timezone.name)
          @slots.select!{|x| !(x >= a && x <= b)}
          @arr<<@range_second
        else
          a = (unavailable[:start]).to_datetime.in_time_zone(timezone.name)
          b = (unavailable[:end]).to_datetime.in_time_zone(timezone.name)
          @range_second = (unavailable[:start]).to_datetime.in_time_zone(timezone.name)..(unavailable[:end]).to_datetime.in_time_zone(timezone.name)
          @slots.select!{|x| !(x >= a && x <= b)}
          @arr<<@range_second
        end
      end
    end

    respond_to do |format|
      format.json
    end
  end

  def send_tip
    if params[:booking_id]
      # @tip_coins = params[:tip_coins]
      @booking = Booking.find(params[:booking_id])

      if @booking.guide.profile_id == current_profile_id
        @type = "Guiding"
        @companion = @booking.explore
      else
        @type = "Exploring"
        @companion = @booking.guide
      end

      @self_wallet = Wallet.find_by(profile_id: current_profile_id)
      @companion_wallet = Wallet.find_by(profile_id: @companion.profile.id)
      if @type == "Exploring"
        #Update wallet_history and wallet coins for Self
        @self_history = WalletHistory.create(wallet_id: @self_wallet.id, cost: -@tip_coins, prev_bal: @self_wallet.coins, new_bal: @self_wallet.coins - @booking.coins,action: nil,source: "Tip from Explorer")
        @self_wallet.update(coins: @self_history.new_bal)

        #Update wallet_history and wallet Tip coins for Companion
        @companion_history = WalletHistory.create(wallet_id: @companion_wallet.id, cost: @tip_coins, prev_bal: @companion_wallet.coins, new_bal: @companion_wallet.coins + @tip_coins,action: nil,source: "Tip for Guide")
        @companion_wallet.update(coins: @companion_history.new_bal)
      else
        #Update wallet_history and wallet coins for Self
        @self_history = WalletHistory.create(wallet_id: @self_wallet.id, cost: -@tip_coins, prev_bal: @self_wallet.coins, new_bal: @self_wallet.coins - @booking.coins,action: nil,source: "Tip from Guide")
        @self_wallet.update(coins: @self_history.new_bal)

        #Update wallet_history and wallet Tip coins for Companion
        @companion_history = WalletHistory.create(wallet_id: @companion_wallet.id, cost: @tip_coins, prev_bal: @companion_wallet.coins, new_bal: @companion_wallet.coins + @tip_coins,action: nil,source: "Tip for Explorer")
        @companion_wallet.update(coins: @companion_history.new_bal)
      end

    end

    flash.now[:success] = "Tip Send!"
    @flashing = flash
    respond_to do |format|
      format.js
    end
  end

  def reservation
  end

  def subject
    if !params["profile_id"].nil?
      if current_user.profile.id != params["profile_id"].to_i
        @categories_list = Profile.includes(guides: :category).find_by_id(params["profile_id"]).guide_categories
        @profile = Profile.find_by_id(params["profile_id"])
      end
    elsif !params["guide_id"].nil?
      if current_user.id != Guide.find_by_id(params["guide_id"]).id
        @categories_list = Guide.find_by_id(params["guide_id"]).category
        @profile = Guide.find_by_id(params["guide_id"]).profile
      end
    end
  end

  def submit_subject
    @guide = Guide.where(profile_id: params[:profile_id],category_id: params["category_id"]).first
    @url = booking_schedule_path(guide_id: @guide.id,learning_goal: params[:goal])
    if Explore.find_by(profile_id: current_profile_id,category_id: params["category_id"].to_i).nil?
      respond_to do |format|
        format.js
      end
    else
      render :js => "window.location = '#{@url}'"
    end
  end

  def schedule
    @edit = params["edit"].nil? ? "" : params["edit"]
    @booking_id = params["id"].nil? ? "" : params["id"]
    @guide = Guide.find_by_id(params["guide_id"])
    if current_user.profile.wallet.nil?
      wallet = Wallet.new(profile: current_user.profile, coins: 0)
      wallet.save!
    end
    @profile = @guide.profile
    @learning_goal = params[:learning_goal]
    @available_coins = current_user.profile.wallet.coins
    if Explore.find_by(profile_id: current_profile_id,category_id: @guide.category.id).nil?
      explore = Explore.new(profile: current_user.profile,category: @guide.category)
      explore.save!
    end
  end

  def confirm_schedule
    @params = scheduling_params
    respond_to do |format|
      format.js
    end
  end

  def confirm
    @params = scheduling_params
    booking = set_create_booking(scheduling_params)
    timezone = Timezone[scheduling_params[:time_zone]]
    puts timezone
    @guide = booking[:guide]
    @session_goal = booking[:session_goal]
    @session_cost = booking[:session_cost]
    @remaining_balance = booking[:remaining_balance]
    @start_time = booking[:start_time]
    @end_time = booking[:end_time]
    @previous_start_time = booking[:previous_start_time]
    @previous_end_time = booking[:previous_end_time]
    @previous_date = booking[:previous_date]
    @date = booking[:date]
    @chest = booking[:chest]
  end

  def submit_request
    @payload = eval(params["payload"])
    booking = set_create_booking(@payload)
    @new_booking =  Booking.new
    @new_booking.guide = booking[:guide]
    @new_booking.title = booking[:guide].category.name
    @new_booking.explore = Explore.where(profile: current_user.profile,category: booking[:guide].category)[0]
    @new_booking.description = booking[:session_goal]
    @new_booking.duration = booking[:duration]
    @new_booking.coins = booking[:session_cost]
    @new_booking.start = Time.zone.parse((booking[:date] +" "+ booking[:start_time])).getutc
    @new_booking.end = Time.zone.parse((booking[:date] +" "+ booking[:end_time])).getutc
    @new_booking.status = "pending"
    @new_booking.identifier = SecureRandom.base64(10)
    @new_booking.client_id = current_profile_id
    @new_booking.recipient_id = booking[:guide].profile_id
    @other_profile = booking[:guide].profile
    @companion = booking[:guide]
    timezone = Timezone[@payload["time_zone"]]

    if @new_booking.save
      @new_booking.video_sessions.create(profile_id: current_user.profile.id)
      @new_booking.video_sessions.create(profile_id: booking[:guide].profile_id)
      flash[:success] = "Booking Successfully Created"

      #Find respective wallet for explorer and update it
      @self_wallet = Wallet.find_by(profile_id: current_profile_id)

      #Update wallet_history and wallet coins for explore(Self)
      @self_history = WalletHistory.create(
                                     wallet_id: @self_wallet.id,
                                     cost: - @new_booking.coins,
                                     prev_bal: @self_wallet.coins,
                                     new_bal: @self_wallet.coins - @new_booking.coins,
                                     action: @new_booking,
                                     source: "Explore")

      @self_wallet.update(coins: @self_history.new_bal)

      Notification.create(recipient: @companion.profile.user, user: current_user, action: "booking", notifiable: @companion.profile.user, url: "/bookings" )

      UserMailer.booking_request_sent(@new_booking).deliver_later #client
      UserMailer.booking_request_pending(@new_booking).deliver_later #recipient

      other_person_schedule_time =  @other_profile.personal_setting.nil? ? 30.minutes :  @other_profile.personal_setting.schedule_time.nil? ? 30.minutes : @other_profile.personal_setting.schedule_time.minutes
      my_schedule_time =  current_user.profile.personal_setting.nil? ? 30.minutes :  current_user.profile.personal_setting.nil? ? 30.minutes : current_user.profile.personal_setting.schedule_time.minutes

      other_mailer_time = @new_booking.start - other_person_schedule_time
      my_mailer_time = @new_booking.start - my_schedule_time

      hour_ago_mail_time = @new_booking.start - 1.hour
      if hour_ago_mail_time.getutc < Time.current.getutc
        BeforeSessionJob.set(wait_until: hour_ago_mail_time).perform_later @new_booking, current_user
        BeforeSessionJob.set(wait_until: hour_ago_mail_time).perform_later @new_booking, @other_profile.user
      end

      StartSessionJob.set(wait_until: my_mailer_time).perform_later @new_booking, profile_booking_path(current_user.profile.id, @new_booking,  :peer_id => @other_profile.id), current_user #client
      StartSessionJob.set(wait_until: other_mailer_time).perform_later @new_booking, profile_booking_path(@other_profile.id, @new_booking,  :peer_id => current_user.profile.id), @other_profile.user #recipient

      redirect_to booking_completed_path
    end
  end

  def completed
  end

  def approve_modal
    @booking = Booking.find_by_id(params[:id])
    @time_slot = @booking
    @timezone = current_profile.time_zone
    @balance = current_profile.wallet.coins
    @profile_id = current_profile.id
    respond_to do |format|
      format.js
    end
  end

  def change_cancel_modal
    @booking = Booking.find_by_id(params[:id])
    @time_slot = @booking
    @timezone = current_profile.time_zone
    @balance = current_profile.wallet.coins
    @profile_id = current_profile.id
    respond_to do |format|
      format.js
    end
  end

  def cancel_modal
    @booking = Booking.find_by_id(params[:id])
    @action = params[:commit].present? ? "session" : "upcoming"
    @timezone = current_profile.time_zone
    @balance = current_profile.wallet.coins
    @extra_fee_detail = cancellation_fee_calculator(Time.zone.now,@booking,@timezone)
    @profile_id = current_profile.id
    respond_to do |format|
      format.js
    end
  end

  def running_late
    @booking = Booking.friendly.find(params[:id])
    message = params[:message]
    if @booking.guide.profile_id == current_profile_id
      @companion = @booking.explore.profile.user
    else
      @companion = @booking.guide.profile.user
    end
    UserMailer.running_late(@companion,message,current_user).deliver_later
    flash.now[:success] = "Emailed #{@companion.full_name}!"
    @flashing = flash
    respond_to do |format|
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def scheduling_params
      params.permit(:guide_id,:goal,:duration,:start_time,:date,:time_zone,:edit,:id)
    end

    def set_create_booking(payload)
      if payload["id"].present?
        booking = Booking.find_by_id(payload["id"])
        timezone = current_user.profile.time_zone
        previous_start_time = booking.start.to_datetime.in_time_zone(timezone).strftime("%I:%M %P")
        previous_end_time = booking.end.to_datetime.in_time_zone(timezone).strftime("%I:%M %P")
        previous_date = booking.start.to_datetime.in_time_zone(timezone).strftime("%B %d, %Y")
      end
      guide = Guide.includes(:category,profile: :user).find_by_id(payload["guide_id"])
      session_goal = payload["goal"]
      session_duration = payload["duration"]
      session_cost = payload["duration"].to_i*10
      chest =  current_profile.wallet.nil? ? 100: current_profile.wallet.coins
      remaining_balance = current_profile.wallet.nil? ? 100: (current_profile.wallet.coins - session_cost)
      personal_timezone = current_user.profile.time_zone
      timezone = payload["time_zone"]
      unfix_date_time = payload["date"].to_time.strftime("%B %d, %Y") + " " + payload["start_time"]
      fix_date_time = unfix_date_time.in_time_zone(timezone).to_datetime.in_time_zone(personal_timezone)
      start_time = fix_date_time.strftime("%I:%M %P")
      end_time = (fix_date_time + payload["duration"].to_i.minutes).strftime("%I:%M %P")
      date = fix_date_time.strftime("%B %d, %Y")

      return {
        guide: guide,
        session_cost: session_cost,
        session_goal: session_goal,
        duration: session_duration,
        timezone: timezone,
        chest: chest,
        remaining_balance: remaining_balance,
        start_time: start_time,
        end_time: end_time,
        date: date,
        unfix: unfix_date_time,
        previous_start_time: previous_start_time,
        previous_end_time: previous_end_time,
        previous_date: previous_date
      }
    end

    def set_booking
      if params[:profile_id].to_i == current_user.profile.id
        current_user.profile.bookings.each do |booking|
          if booking[:slug] == params[:id]
            Profile.find(params[:peer_id]).bookings.each do |peer_booking|
              if booking.id == peer_booking.id && booking.slug == params[:id] && peer_booking.slug == params[:id]
                @other_profile = Profile.find(params[:peer_id])
                @booking = Booking.friendly.find(params[:id])
              end
            end
          end
        end
      end
    end

    def unavialabilities(availabilities)
      @check = []
      availabilities.each do |record|
        hash = {}
        hash1 = {}
        hash["daysOfWeek"] = [record["week_day"]]
        hash1["daysOfWeek"] = [record["week_day"]]
        hash["title"] = "Unavailable"
        hash1["title"] = "Unavailable"
        if record["start_time"].nil?
          hash["startTime"] = "00:00:00"
          hash["endTime"] = "23:59:00"
          hash1["allDay"] = true
        else
          hash["startTime"] = "00:00:00"
          hash["endTime"] = record["start_time"].strftime("%H:%M:%S")
        end
        if record["end_time"].nil?
          hash1["startTime"] = "00:00:00"
          hash1["endTime"] = "23:59:00"
          hash1["allDay"] = true
        else
          hash1["startTime"] = record["end_time"].strftime("%H:%M:%S")
          hash1["endTime"] = "23:59:00"
        end
        if !record["timing"].nil?
          record["timing"].each do |timing|
            hash2 = {}
            hash2["daysOfWeek"] = [record["week_day"]]
            hash1["className"] = "unavailable"
            hash2["title"] = "Unavailable"
            hash2["startTime"] = timing[0]
            hash2["endTime"] = timing[1]
            @check << hash2
          end
        end
        hash["className"] = "unavailable"
        hash1["className"] = "unavailable"
        @check << hash << hash1
      end
      return @check
    end

    def booking_params
      params.require(:booking).permit(:title,:date_range, :start, :end, :duration, :cancel_date, :status,:description)
    end
    def format_time (timeElapsed)
      @timeElapsed = timeElapsed
      seconds = @timeElapsed % 60
      minutes = (@timeElapsed / 60) % 60
      hours = (@timeElapsed/3600)
      return hours.to_s + ":" + format("%02d",minutes.to_s) + ":" + format("%02d",seconds.to_s)
    end

    def current_profile_id
      current_user.profile.id
    end

    def cancellation_fee_calculator(time,booking,timezone)
      if time < booking.start.to_datetime.in_time_zone(timezone)
        difference = (booking.start.to_datetime.in_time_zone(timezone) - time).to_i.abs
        puts (difference < 86400)
        if difference > 86400
          cancellation_fee = 0
          late_fee = 0
        elsif difference.between?(10800, 86400) #between 3hrs to 24hrs
          cancellation_fee = 0.1 * booking.coins
          late_fee = 0
        elsif difference.between?(1800, 10800) #between 30mins to 3hrs
          cancellation_fee = 0.2 * booking.coins
          late_fee = 0.1 * booking.coins
        else
          cancellation_fee = 0.2 * booking.coins #less than 30 mins
          late_fee = 0.2 * booking.coins
        end
        total_fee = cancellation_fee + late_fee

        return {total_fee: total_fee, cancellation_fee: cancellation_fee, late_fee: late_fee}
      else
        return {total_fee: 0, cancellation_fee: 0, late_fee: 0}
      end
    end

    def current_profile
      current_user.profile
    end

    def set_booking_status
      current_user.profile.bookings.each do |booking|
        if booking.status == "pending" #submitted bookings
          if Time.zone.now > booking.start.to_datetime.in_time_zone(current_profile.time_zone)
            #reimburse money and change status to 2
            explorer_wallet = Wallet.find_by(profile_id: booking.explore.profile.id)
            next if explorer_wallet.nil?
            explorer_history = WalletHistory.create(
                                            wallet_id: explorer_wallet.id,
                                            cost: booking.coins,
                                            prev_bal: explorer_wallet.coins,
                                            new_bal: explorer_wallet.coins + (booking.coins.nil? ? 0 : booking.coins),
                                            action: booking,
                                            source: "Reimbursement")

            explorer_wallet.update(coins: explorer_history.new_bal)

            booking.update_attributes({flag: true, status: 2})
          end
        elsif booking.status == "upcoming" #upcoming bookings
          if Time.zone.now > booking.end.to_datetime.in_time_zone(current_profile.time_zone)
            booking.update_attributes({flag: true, status: 2})
          end
        end
      end
    end
    def sort_column
      Booking.column_names.include?(params[:sort]) ? params[:sort] : "start"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end



end
