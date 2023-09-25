class CategoriesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  helper_method :sort_column, :sort_direction
  before_action :set_category, only: [:show,:guides,:explorers,:projects, :edit_types]

  def index
    @filterrific = initialize_filterrific(
      Category.order(sort_column + " " + sort_direction),
      params[:filterrific]
    ) or return
    @categories = @filterrific.find.page(params[:page])
    respond_to do |format|
      format.html
      format.js
    end

  end

  def show
    if params[:search]
      @results = Category.verified.ransack(name_cont: params[:search].downcase).result
    else
      model1 = Explore.includes(:category,profile: :user)
      model2 = Guide.includes(:category,profile: :user)
      @category_exits = current_user.profile.explores.find_by(category_id: @category.id).present? || current_user.profile.guides.find_by(category_id: @category.id).present?
      @results_explores = model1.with_category(@category.id).exclude_user(current_user).uniq
      @results_guides = model2.with_category(@category.id).exclude_user(current_user).uniq
    end
  end

  def create
    @category = Category.new(catgeory_params)
    if current_user.roles.last.name == "admin"
      @category.verified = true
    else
      @category.verified = false
    end

    @category.save!
    puts params["type"]
    if  params["type"] == "Explore"
      explore = Explore.new
      explore.profile_id = params["profile_id"]
      explore.category_id = @category.id
      explore.save!
    elsif params["type"] == "Guide"
      guide = Guide.new
      guide.profile_id = params["profile_id"]
      guide.category_id = @category.id
      guide.save!
    end

    if current_user.roles.pluck(:name).uniq[0] != "admin"
      UserMailer.category_submission_received(current_user).deliver_later
      users = User.with_role :admin
      users.each do |user|
        UserMailer.category_submission_send_admin(user,@category,current_user).deliver_later
        Notification.create(recipient: user, user: current_user, action: "new_category", notifiable: @category,url: "/categories")
      end
    end

    flash.now[:success] = "Your category request has been submitted for review."
    @flashing = flash
    respond_to do |format|
      format.html {redirect_to categories_path}
      format.js
    end

  end

  def update
    @category=Category.find(params[:editid])
    old_status = @category.verified
    if !@category.verified
      if Explore.find_by(category: @category).nil?
        user_profile = Guide.find_by(category: @category)
      else
        user_profile = Explore.find_by(category: @category)
      end
    end
    @category.name = params[:name]
    @category.description = params[:description]
    if !params[:url].empty?
      @category.url = params[:url]
    end
    @category.verified = params[:verified]
    @category.save!
    if @category.verified && @category.verified != old_status
      if !user_profile.nil?
        Notification.create(recipient: user_profile.profile.user, user: current_user, action: "category_accepted", notifiable: @category, url: @category.url)
        UserMailer.category_submission_approved(user_profile.profile.user, @category).deliver_later
      end
    end
    redirect_to categories_path, notice: 'Category was successfully updated.'
  end

  def edit_types
    if  params["type"] == "Explore"
      explore = Explore.new
      explore.profile_id = current_user.profile.id
      explore.category_id = @category.id
      explore.save!
      flash[:success] = "Category addded in your #{params["type"]} list."
    elsif params["type"] == "Guide"
      guide = Guide.new
      guide.profile_id = current_user.profile.id
      guide.category_id = @category.id
      guide.save!
      flash[:success] = "Category addded in your #{params["type"]} list."
    elsif params["type"] == "removeGuide"
      guide = Guide.find_by(category: @category, profile: current_user.profile)
      if !guide.nil?
        guide.destroy
        flash[:error] = "Category removed from your Guide list."
      end
    elsif params["type"] == "removeExplore"
      explore = Explore.find_by(category: @category, profile: current_user.profile)
      if !explore.nil?
        explore.destroy
        flash[:error] = "Category removed from your Explore list."
      end
    end
    @flashing = flash
    render js: %(window.location.href='#{category_path(@category)}')
  end

  def destroy
    Category.find(params[:id]).destroy
    redirect_to categories_path, notice: 'Category was successfully deleted.'
  end

  def explorers
    if params[:search]
      @results = Category.verified.ransack(name_cont: params[:search].downcase).result
    else
      model = Explore.includes(:category,profile: :user)
      @profiles= model.with_category(@category.id).exclude_user(current_user)
      @category_exits = current_user.profile.explores.find_by(category_id: @category.id).present? || current_user.profile.guides.find_by(category_id: @category.id).present?
    end
  end

  def guides
    if params[:search]
      @results = Category.verified.ransack(name_cont: params[:search].downcase).result
    else
      model = Guide.includes(:category,profile: :user)
      @profiles= model.with_category(@category.id).exclude_user(current_user)
      @category_exits = current_user.profile.explores.find_by(category_id: @category.id).present? || current_user.profile.guides.find_by(category_id: @category.id).present?
    end
  end

  def projects
    if params[:search]
      @results = Category.verified.ransack(name_cont: params[:search].downcase).result
    else
      model = Project.includes(:categories,profile: :user)
      @profiles= model.where(:categories=>{id:@category.id}).exclude_user(current_user)
      @category_exits = current_user.profile.explores.find_by(category_id: @category.id).present? || current_user.profile.guides.find_by(category_id: @category.id).present?
    end
  end

  def filter_result
    query_param = fetch_country_params(params)
    @category = Category.verified.friendly.find(params[:category_name])

    if params[:filter] == 'popular'
      model1 = Explore.includes(:category,profile: :user)
      model2 = Guide.includes(:category,profile: :user)

      if params[:country].nil?
        @results_explores = model1.with_category(@category.id).exclude_user(current_user)
        @results_guides = model2.with_category(@category.id).exclude_user(current_user)
      else
        @results_explores = model1.where(category_id: @category.id,:profiles=>query_param).exclude_user(current_user)
        @results_guides = model2.where(category_id: @category.id,:profiles=>query_param).exclude_user(current_user)
      end

    elsif params[:filter] == 'top'
      model1 = ExploreRating.includes(profile: :user,explore: [:category])
      model2 = GuideRating.includes(profile: :user,explore: [:category])

      if params[:country].nil?
        @results_explores = model1.rate_desc.where(category_id: @category.id,explore_id: not_self_explore_category_ids).pluck(:explore_id).uniq.map{|x| Explore.find(x)}
        @results_guides = model2.rate_desc.where(category_id: @category.id,explore_id: not_self_guide_category_ids).pluck(:guide_id).uniq.map{|x| Guide.find(x)}
      else
        @results_explores = model1.rate_desc.where(category_id: @category.id,explore_id: not_self_explore_category_ids,:profiles=>query_param).pluck(:explore_id).uniq.map{|x| Explore.find(x)}
        @results_guides = model2.rate_desc.where(category_id: @category.id,explore_id: not_self_guide_category_ids,:profiles=>query_param).pluck(:guide_id).uniq.map{|x| Guide.find(x)}
      end
    elsif params[:filter] == 'most'
      model = Booking.includes(explore: [:profile,:category])

      if params[:country].nil?
        completed_session_explores = model.where(:status=>2,:explores=>{:categories=>{id: @category.id}}).pluck(:explore_id)
        completed_session_guides = model.where(:status=>2,:guides=>{:categories=>{id: @category.id}}).pluck(:guide_id)
      else
        completed_session_explores = model.where(:status=>2,:explores=>{:categories=>{id: @category.id},:profiles=>query_param}).pluck(:explore_id)
        completed_session_guides = model.where(:status=>2,:guides=>{:categories=>{id: @category.id},:profiles=>query_param}).pluck(:guide_id)
      end
      self_explore = self_explore_category_ids
      self_guide = self_guide_category_ids
      most_explores = completed_session_explores - self_explore
      most_guides = completed_session_guides - self_guide

      @results_explores = most_explores.map{|x| Explore.find(x) if !Explore.where(id:x).exclude_user(current_user).empty?}.compact
      @results_guides = most_guides.map{|x| Guide.find(x) if !Guide.where(id:x).exclude_user(current_user).empty?}.compact

    end
    @filter = params[:filter]
    respond_to do |format|
      format.js
    end
  end

  def filter_result_explore
    query_param = fetch_country_params(params)
    @category = Category.friendly.find(params[:category_name])

    if params[:filter] == 'popular'
      model = Explore.includes(:category,profile: :user)
      if params[:country].nil?
        @results = model.with_category(@category.id).exclude_user(current_user)
      else
        @results = model.where(category_id: @category.id,:profiles=>query_param).exclude_user(current_user)
      end

    elsif params[:filter] == 'top'
      model = ExploreRating.includes(profile: :user,explore: [:category])
      if params[:country].nil?
        @results = model.rate_desc.where(category_id: @category.id,explore_id: not_self_explore_category_ids).pluck(:explore_id).uniq.map{|x| Explore.find(x)}
      else
        @results = model.rate_desc.where(category_id: @category.id,explore_id: not_self_explore_category_ids,:profiles=>query_param).pluck(:explore_id).uniq.map{|x| Explore.find(x)}
      end
    elsif params[:filter] == 'most'
      model = Booking.includes(explore: [:profile,:category])

      if params[:country].nil?
        completed_session = model.where(:status=>2,:explores=>{:categories=>{id: @category.id}}).pluck(:explore_id)
      else
        completed_session = model.where(:status=>2,:explores=>{:categories=>{id: @category.id},:profiles=>query_param}).pluck(:explore_id)
      end
      self_explore = self_explore_category_ids
      most = completed_session - self_explore
      @results = most.map{|x| Explore.find(x) if !Explore.where(id:x).exclude_user(current_user).empty?}.compact
    end
    @filter = params[:filter]
    respond_to do |format|
      format.js
    end
  end

  def filter_result_guide
    query_param = fetch_country_params(params)
    @category = Category.friendly.find(params[:category_name])

    if params[:filter] == 'popular'
      model = Guide.includes(:category,profile: :user)
      if params[:country].nil?
        @results = model.with_category(@category.id).exclude_user(current_user)
      else
        @results = model.where(category_id: @category.id,:profiles=>query_param).exclude_user(current_user)
      end

    elsif params[:filter] == 'top'
      model = GuideRating.includes(profile: :user,explore: [:category])
      if params[:country].nil?
        @results = model.rate_desc.where(category_id: @category.id,guide_id: not_self_guide_category_ids).pluck(:guide_id).uniq.map{|x| Guide.find(x)}
      else
        @results = model.rate_desc.where(category_id: @category.id,guide_id: not_self_guide_category_ids,:profiles=>query_param).pluck(:guide_id).uniq.map{|x| Guide.find(x)}
      end
    elsif params[:filter] == 'most'
      model = Booking.includes(guide: [:profile,:category])
      if params[:country].nil?
        completed_session = model.where(:status=>2,:guides=>{:categories=>{id: @category.id}}).pluck(:guide_id)
      else
        completed_session = model.where(:status=>2,:guides=>{:categories=>{id: @category.id},:profiles=>query_param}).pluck(:guide_id)
      end
      self_explore = self_explore_category_ids
      most = completed_session - self_explore
      @results = most.map{|x| Guide.find(x)}
    end
    @filter = params[:filter]
    respond_to do |format|
      format.js
    end
  end

  def filter_result_project
    query_param = fetch_country_params(params)
    category = Category.friendly.find(params[:category_name])
    model = Project.includes(:categories,profile: :user)

    if params[:filter] == 'popular'
      if params[:country].nil?
        @results = model.where(:categories=>{id:category.id}).exclude_user(current_user)
      else
        @results = model.where(:categories=>{id:category.id},:profiles=>query_param).exclude_user(current_user)
      end
    elsif params[:filter] == 'status'
      if params[:country].nil?
        @idea = model.where(:status=>"idea",:categories=>{id:category.id}).exclude_user(current_user)
        @progress = model.where(:status=>"progress",:categories=>{id:category.id}).exclude_user(current_user)
        @completed = model.where(:status=>"completed",:categories=>{id:category.id}).exclude_user(current_user)
      else
        @idea = model.where(:categories=>{id:category.id},:status=>"idea",:profiles=>query_param).exclude_user(current_user)
        @progress = model.where(:categories=>{id:category.id},:status=>"progress",:profiles=>query_param).exclude_user(current_user)
        @completed = model.where(:categories=>{id:category.id},:status=>"completed",:profiles=>query_param).exclude_user(current_user)
      end
      @results = []
    elsif params[:filter] == 'help'
      if params[:country].nil?
        @help_needed = model.where(:categories=>{id:category.id},:help=>1).exclude_user(current_user)
      else
        @help_needed = model.where(:categories=>{id:category.id},:help=>1,:profiles=>query_param).exclude_user(current_user)
      end
      @results = []
    else
      if params[:country].nil?
        @most_recent = model.where(:categories=>{id:category.id}).order(created_at: :desc).exclude_user(current_user)
      else
        @most_recent = model.where(:categories=>{id:category.id},:profiles=>query_param).order(created_at: :desc).exclude_user(current_user)
      end
      @results = []
    end
    @filter = params[:filter]
    respond_to do |format|
      format.js
    end
  end

  def search_result
    @categories = Category.all.verified.ransack(name_cont: params[:search].downcase).result
    guides = Guide.includes(:category,profile: :user).ransack(profile_user_firstname_or_profile_user_lastname_cont_any: params[:search]).result.uniq.exclude_user(current_user)
    explores = Explore.includes(:category,profile: :user).ransack(profile_user_firstname_or_profile_user_lastname_cont_any: params[:search]).result.uniq.exclude_user(current_user)
    @users = (guides + explores).uniq{|user| user.profile_id}
    @results = @categories + @users
  end

  private

    def set_category
      @category = Category.friendly.find(params[:id])
      @created_at = @category.created_at
    end

    def top_category_explorer(top_explores)
      @explores = Explore.all
      if !top_explores.empty?
        category = top_explores[0].category
        @first_category_name_explore =  category.name
        @first_category_explore= @explores.includes(:category,profile: :user).where(:category_id => category.id).exclude_user(current_user)
      else
        @first_category_name_explore = "None"
        @first_category_explore = []
      end
      return {
        top_category_name: @first_category_name_explore,
        top_category_explore: @first_category_explore
      }
    end

    def not_self_explore_category_ids
      if current_user.profile
        category_ids_checked= current_user.profile.explores.pluck(:category_id)
        Explore.where(category_id: category_ids_checked).exclude_user(current_user).pluck(:id)
      else
        []
      end
    end

    def not_self_guide_category_ids
      if current_user.profile
        guide_ids_checked = current_user.profile.guides.pluck(:category_id).uniq
        Guide.where(category_id: guide_ids_checked).exclude_user(current_user).pluck(:id)
      else
        []
      end
    end


    def current_profile_id
      if current_user.profile
        current_user.profile.id
      end
    end

    def current_profile
      current_user.profile
    end

    def self_guide_category_ids
      if current_user.profile
        Guide.where(profile: current_user.profile).pluck(:id)
      else
        []
      end
    end

    def self_explore_category_ids
      if current_user.profile
        Explore.where(profile: current_user.profile).pluck(:id)
      else
        []
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def catgeory_params
      params.permit(:name,:url,:description)
    end

    def sort_column
      Category.column_names.include?(params[:sort]) ? params[:sort] : "verified"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

end
