class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile, only: [:show, :edit, :update, :destroy]

  # GET /profiles
  # GET /profiles.json
  def index
    if current_user.profile
      @profiles = Profile.all
      @user = current_user
      if current_user.profile
        @profile = current_user.profile
        @explores = @profile.explore_categories.select{|category| category.verified}.uniq
        @guides = @profile.guide_categories.select{|category| category.verified}.uniq
        @new_profile = false
        @projects = @profile.projects.includes(:projects_categories,:categories)
        @current_explore_rating = ExploreRating.includes(:category,guide: [profile: :user]).where(profile: @profile,guides:{profile: current_user.profile}).sort_by_created_desc.first
        @current_guide_rating = GuideRating.includes(:category,explore: [profile: :user]).where(profile: @profile,explores:{profile: current_user.profile}).sort_by_created_desc.first
        @explore_ratings = ExploreRating.includes(:category,guide: [profile: :user]).where(profile: @profile).sort_by_created_desc
        @guide_ratings = GuideRating.includes(:category,explore: [profile: :user]).where(profile: @profile).sort_by_created_desc

      else
        @new_profile = true
        @profile = Profile.new
        @explores = []
        @guides = []
      end
      if  profile_builder_complete[:profile_nil]
        flash[:notice] = 'Complete your profile first'
        redirect_to first_page_introduction_path
      elsif profile_builder_complete[:all_empty]
        flash[:notice] = 'Complete your Availability first'
        redirect_to availabilty_introduction_path
      else
        current_user.update(builder: true)
      end


      @filterrific = initialize_filterrific(
        Category.verified.order("RANDOM()"),
        params[:filterrific]
      ) or return
      @categories = @filterrific.find.page(params[:page])
      respond_to do |format|
        format.html
        format.js
      end
      @list = current_user.profile.explore_categories.uniq.select{|category| category.verified}.pluck(:id)
      @listg = current_user.profile.guide_categories.uniq.select{|category| category.verified}.pluck(:id)

      @category = Category.all.verified

    else
      redirect_to first_page_introduction_path
      flash[:error] = "Build your profile first"
    end
  end

  # GET /profiles/1
  # GET /profiles/1.json
  def show
    if params["id"].to_i == current_user.profile.id || params["id"] == current_user.profile.slug
      redirect_to profiles_path
    else
      @user = @profile.user
      @explores = @profile.explore_categories.uniq.select{|category| category.verified}
      @guides = @profile.guide_categories.uniq.select{|category| category.verified}
      @explore_categories = @profile.explore_categories.uniq.select{|category| category.verified}
      @guide_categories = @profile.guide_categories.uniq.select{|category| category.verified}
      @projects = @profile.projects.includes(:projects_categories,:categories)
      @current_explore_rating = ExploreRating.includes(guide: [profile: :user]).where(profile: @profile,guides:{profile: current_user.profile}).sort_by_created_desc.first
      @current_guide_rating = GuideRating.includes(explore: [profile: :user]).where(profile: @profile,explores:{profile: current_user.profile}).sort_by_created_desc.first
      @explore_ratings = ExploreRating.includes(guide: [profile: :user]).where(profile: @profile).sort_by_created_desc
      @guide_ratings = GuideRating.includes(explore: [profile: :user]).where(profile: @profile).sort_by_created_desc

    end
  end

  # GET /profiles/new
  def new
  end

  # GET /profiles/1/edit
  def edit
  end

  # POST /profiles
  # POST /profiles.json
  def create
    @params = profile_params
    if params["birth-day"].to_i > 31
      redirect_to first_page_introduction_path, flash: { error: "Invalid date" }
    elsif Time.now.year - params["birth-year"].to_i < 13
      redirect_to first_page_introduction_path, flash: { error: "Age must be greater than 13 years" }
    else
      if @params["country"]
        @params["country"] = CS.get[profile_params[:country].to_sym]
      end
      if @params["state"].size==2 || @params["state"].size==3
        @states = CS.get profile_params[:country].to_sym
        @params["state"] = @states[profile_params[:state].to_sym]
      end
      @params["birth_date"] = (params["birth-year"] + "-" + params["birth-month"] + "-" + params["birth-day"]).to_date
      if current_user.profile #if Profile already exists
        @profile = current_user.profile
        @projects = @profile.projects

        if !@profile.city.nil? & profile_params[:city].empty?
          @params["city"] = @profile.city
        else
          @params["city"] = profile_params[:city]
          coordinates = fetch_coordinates(@params["state"],@params["city"])
          @params["latitude"] = coordinates[1]
          @params["longitude"] = coordinates[0]
          @params["time_zone"] = Timezone.lookup(coordinates[1],coordinates[0]).name
          puts @params["time_zone"]
        end

        if !params["edit-profile-languages"].nil?
          @lan_array = JSON.parse(params["edit-profile-languages"])
          @params["languages"] = @lan_array
        end
        if !@profile.profile_photo.nil? & params["profile_photo"].empty?
          @params["profile_photo"] = @profile.profile_photo
        else
          @params["profile_photo"] = params["profile_photo"].empty? ? nil : params["profile_photo"]
        end
        if !@profile.banner_photo.nil? & params["banner_photo"].empty?
          @params["banner_photo"] = @profile.banner_photo
        else
          @params["banner_photo"] = params["banner_photo"].empty? ? nil : params["banner_photo"]
        end
        respond_to do |format|
          if @profile.update_attributes(@params)
            format.html { redirect_to profiles_path, notice: 'Profile was successfully updated.' }
            format.json { render :show, status: :ok, location: @profile }
          else
            format.html { render :edit }
            format.json { render json: @profile.errors, status: :unprocessable_entity }
          end
        end
      else
        if(params[:first_signup] == "true")
          @user = current_user
          @profile = Profile.new()  #create new Profile
          @profile.user = @user
          @lan_array = JSON.parse(params["languages"])
          @params["languages"] = @lan_array
          # coordinates = fetch_coordinates(@params["state"],@params["city"])
          # @params["latitude"] = coordinates[1]
          # @params["longitude"] = coordinates[0]
          # @params["time_zone"] = Timezone.lookup(coordinates[1],coordinates[0]).name
          @params["birth_date"] = (params["birth-year"] + "-" + params["birth-month"] + "-" + params["birth-day"]).to_date
          respond_to do |format|
            if @profile.update(@params)
              personal_setting = current_user.profile.personal_setting
              if personal_setting.nil?
                PersonalSetting.create(profile: @profile)
              else
                personal_setting.update(profile: @profile)
              end
              format.html { redirect_to '/profile/explores', success: 'Profile was successfully updated.' }
              format.json { render :show, status: :ok, location: @profile }
            else
              format.html { render :edit }
              format.json { render json: @profile.errors, status: :unprocessable_entity }
            end
          end
      end
    end
    end

end

def update
  @params = profile_params
  if @params["country"]
    @params["country"] = CS.get[profile_params[:country].to_sym]
  end
  if @params["state"].size==2 || @params["state"].size==3
    @states = CS.get profile_params[:country].to_sym
    @params["state"] = @states[profile_params[:state].to_sym]
  end
  # coordinates = fetch_coordinates(@params["state"],@params["city"])
  # @params["latitude"] = coordinates[1]
  # @params["longitude"] = coordinates[0]
  # @params["time_zone"] = Timezone.lookup(coordinates[1],coordinates[0]).name

  @profile = current_user.profile
  @projects = @profile.projects
  if params["birth-year"].present? || params["birth-month"].present? || params["birth-day"].present?
    @params["birth_date"] = (params["birth-year"] + "-" + params["birth-month"] + "-" + params["birth-day"]).to_date
  end
  if params["first_signup"] == "true"
    if !params["languages"].empty?
      @lan_array = JSON.parse(params["languages"])
      @params["languages"] = @lan_array
    else
      @params["languages"] = @profile.languages
    end
  else
    if !params["edit-profile-languages"].empty?
      @lan_array = JSON.parse(params["edit-profile-languages"])
      @params["languages"] = @lan_array
    end
  end

  respond_to do |format|
    if @profile.update(@params)
      if params["first_signup"] == "true"
        format.html { redirect_to '/profile/explores', success: 'Profile was successfully updated.' }
      else
        format.html { redirect_to profiles_path, notice: 'Profile was successfully updated.' }
      end
      format.json { render :show, status: :ok, location: @profile }
    else
      format.html { render :edit }
      format.json { render json: @profile.errors, status: :unprocessable_entity }
    end
  end
end

  def introduction
    if current_user.profile.nil?
      @profile = Profile.new(profile_params)
    else
      @profile = current_user.profile
    end

  end

  def explores
    if current_user.profile
      @filterrific = initialize_filterrific(
        Category.verified.order("RANDOM()"),
        params[:filterrific]
      ) or return
      @categories = @filterrific.find.page(params[:page])
      respond_to do |format|
        format.html
        format.js
      end

      @profile = current_user.profile
      @list = @profile.explore_categories.uniq.select{|category| category.verified}.pluck(:id)
      @explore = Explore.new(profile_params)
    else
      redirect_to first_page_introduction_path
      flash[:error] = "Build your profile first"
    end
  end

  def guides
    if current_user.profile
      @filterrific = initialize_filterrific(
        Category.verified.order("RANDOM()"),
        params[:filterrific]
      ) or return
     @categories = @filterrific.find.page(params[:page])
      respond_to do |format|
        format.html
        format.js
      end

      @profile = current_user.profile
      @listg = @profile.guide_categories.uniq.uniq.select{|category| category.verified}.pluck(:id)
      @guide = Guide.new(profile_params)
    else
      redirect_to first_page_introduction_path
      flash[:error] = "Build your profile first"
    end
  end

  def projects
    if current_user.profile
      @projects = current_user.profile.projects.includes(:categories).sort_by_created_desc
    else
      redirect_to first_page_introduction_path
      flash[:error] = "Build your profile first"
    end
  end

  def availabilty
    if current_user.profile
      availabilities =  current_user.profile.availabilities
      @formatted_availabilty = format_availability(availabilities)
      puts @formatted_availabilty
      @personal_setting_schedule_time = current_user.profile.personal_setting.nil? ? "" : current_user.profile.personal_setting.schedule_time
      @personal_setting_buffer_time = current_user.profile.personal_setting.nil? ? "" : current_user.profile.personal_setting.buffer_time
      puts @personal_setting_schedule_time
      puts @personal_setting_buffer_time
    else
      redirect_to first_page_introduction_path
      flash[:error] = "Build your profile first"
    end
  end

  def availabilty_booking_create
    if current_user.profile
      @model = Availability.new
      @availabilty = JSON.parse(params[:availabilty])
      current_user.profile.update({time_zone: params[:timezone]})
      personal_setting = current_user.profile.personal_setting
      if personal_setting.nil?
        personal_setting = PersonalSetting.new({schedule_time: params[:session_schedule].to_i, buffer_time: params[:buffer_time].to_i, profile: current_user.profile})
        personal_setting.save!
      else
        personal_setting.update({schedule_time: params[:session_schedule].to_i, buffer_time: params[:buffer_time].to_i})
      end
      day_of_week_hash = Date::DAYNAMES.map.with_index{ |x, i| [x, i] }.to_h
      mark_as_off_day =  Date::DAYNAMES - @availabilty.map.with_index{ |x, i|  x[0]}
      if current_user.profile.availabilities.empty?
        @availabilty.each do |day,time_array|
          @model = Availability.new
          @model.week_day = day_of_week_hash[day]
          @model.profile = current_user.profile
          time_array.each do |time|
            @model.start_time = refactor_timing(time_array)[:start_time]
            @model.end_time = refactor_timing(time_array)[:end_time]
            @model.timing = refactor_timing(time_array)[:unavailable_timing]
            @model.save
          end
        end
        if !mark_as_off_day.empty?
          mark_as_off_day.each do |day|
            @model = Availability.new
            @model.week_day = day_of_week_hash[day]
            @model.profile = current_user.profile
            @model.full_day_off = true
            @model.start_time = nil
            @model.end_time = nil
            @model.save
          end
        end
      else
        current_user.profile.update({time_zone: params[:timezone]})
        current_user.profile.personal_setting.update({schedule_time: params[:session_schedule].to_i, buffer_time: params[:buffer_time].to_i})
        puts @availabilty
        puts mark_as_off_day
        @availabilty.each do |day,time_array|
          puts refactor_timing(time_array)
          @current_model = current_user.profile.availabilities.find_by_week_day(day_of_week_hash[day])
          time_array.each do |time|
            @start_time = refactor_timing(time_array)[:start_time]
            @end_time = refactor_timing(time_array)[:end_time]
            @timing = refactor_timing(time_array)[:unavailable_timing]
            if @current_model.nil?
              @model = Availability.new
              @model.profile = current_user.profile
              @model.week_day = day_of_week_hash[day]
              @model.start_time = @start_time
              @model.end_time = @end_time
              @model.timing = @timing
              @model.save
            else
              @current_model.update({full_day_off: false})
              @current_model.update({start_time: @start_time})
              @current_model.update({end_time: @end_time})
              @current_model.update({timing: @timing})
              @model.save
            end
          end
        end
        if !mark_as_off_day.empty?
          mark_as_off_day.each do |day|
            @current_model = current_user.profile.availabilities.find_by_week_day(day_of_week_hash[day])
            if @current_model.nil?
              @model = Availability.new
              @model.week_day = day_of_week_hash[day]
              @model.profile = current_user.profile
              @model.full_day_off = true
              @model.update({start_time: nil})
              @model.update({end_time: nil})
              @model.save
            else
              @current_model.update({start_time: nil})
              @current_model.update({end_time: nil})
              @current_model.update({full_day_off: true})
              @current_model.save
            end
          end
        end
      end
      flash[:success] = "Availability Schedule Updated"
      if params[:first].to_i == 1
        redirect_to profile_completed_path
      else
        redirect_to calendars_path
      end
    else
      redirect_to first_page_introduction_path
      flash[:error] = "Build your profile first"
    end
  end


  def completed
    if current_user.profile
      wallet = Wallet.find_by_profile_id(current_user.profile.id)
      explores = current_user.profile.explores.empty?
      guides = current_user.profile.guides.empty?
      projects = current_user.profile.projects.empty?
      availability = current_user.profile.availabilities.empty?
      # all_empty = explores || guides || projects || availability

      if availability
        redirect_to availabilty_introduction_path
        flash[:error] = "Add Availabilty to claim reward!"
      end

    else
      redirect_to first_page_introduction_path
      flash[:error] = "Build your profile first"
    end
  end

  def claim_reward
    wallet = Wallet.find_by_profile_id(current_user.profile.id)
    if wallet.nil?
      @wallet = Wallet.new
      @wallet.profile = current_user.profile
      @wallet.coins = 1200
      if @wallet.save
        WalletHistory.create(wallet_id: @wallet.id,cost: @wallet.coins,prev_bal: 0,new_bal: @wallet.coins,action: nil, source: "Reward")
      end
      current_user.update(builder: true)
      flash.now[:success] = "Reward for completing profile added!!!"
    end
    @flashing = flash
    respond_to do |format|
      format.js
    end
  end

  def change_password
    @user = current_user
    if @user.valid_password?(params[:current_password])
      if params[:new_password] == params[:re_type_password]
        @user.password = params[:new_password]
        @user.save
        flash.now[:success]= 'Password Changed!!!'
      else
        flash.now[:error]= 'Both Passwords didn\'t match!!!'
      end
    else
      flash.now[:error]= 'Incorrect Current Password!!!'
    end
    @flashing = flash
    respond_to do |format|
      format.js
    end

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_profile
      profile = Profile.includes(:user).friendly.find(params[:id])
      if !current_user.profile.blocked_users.include? profile.id || profile == current_user.profile
        @profile = profile
      end
    end

    def refactor_timing(time_array)
      refactor_array = time_array.flatten.map{|x| Time.zone.parse(x)}.each_slice(2).to_a
      range_form = refactor_array.map {|x| x[0]..x[1]}
      s=merge_ranges(range_form)
      s=s.map{|x| x.to_s.split('..')}
      s=s.map{|v| [Time.zone.parse(v[0]).strftime("%H:%M"),Time.zone.parse(v[1]).strftime("%H:%M")]}
      sorted_timing = s.flatten.map{|x| Time.zone.parse(x)}.sort
      start_time = sorted_timing[0].strftime("%H:%M")
      end_time = sorted_timing[-1].strftime("%H:%M")
      sorted_timing = sorted_timing[1..-2].map{|s| s.strftime("%H:%M")}
      unavailable_timing = sorted_timing.each_slice(2).to_a
      return {
        start_time: start_time,
        end_time: end_time,
        unavailable_timing: unavailable_timing.empty? ? nil : unavailable_timing
      }
    end

    def merge_ranges(ranges)
      ranges = ranges.sort_by {|r| r.first }
      *outages = ranges.shift
      ranges.each do |r|
        lastr = outages[-1]
        if lastr.last >= r.first - 1
          outages[-1] = lastr.first..[r.last, lastr.last].max
        else
          outages.push(r)
        end
      end
      outages
    end

    def format_time (timeElapsed)
      @timeElapsed = timeElapsed
      seconds = @timeElapsed % 60
      minutes = (@timeElapsed / 60) % 60
      hours = (@timeElapsed/3600)
      return hours.to_s + ":" + format("%02d",minutes.to_s) + ":" + format("%02d",seconds.to_s)
    end

    def date_of_next(day)
      date  = Date.parse(day)
      delta = date > Date.today ? 0 : 7
      date + delta
    end

    def process_time(day,time)
      @raw_start = Time.zone.parse(time[0]).to_s.split(' ')[1]
      @raw_end = Time.zone.parse(time[1]).to_s.split(' ')[1]
      @date_next = date_of_next(day).to_s
      {start: @date_next + "T" + @raw_start, end: @date_next + "T" + @raw_end}
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def profile_params
      params.permit(:state,:country,:profile_photo,:banner_photo,:time_zone,:bio,:contact_no,:birth_date,:city,:state,:languages,:latitude,:longitude)
    end

    # def fetch_coordinates(state,city)
    #   key = Rails.application.secrets.mapbox_api_key
    #   url = "https://api.mapbox.com/geocoding/v5/mapbox.places/#{state}+" "+#{city}.json?access_token=#{key}"
    #   print url
    #   body = RestClient::Request.execute( method: "get",url: URI.encode(url))
    #   response = JSON.parse(body)
    #   return response["features"][0]["geometry"]["coordinates"]
    # end
end
