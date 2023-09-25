class ExploresController < ApplicationController
  before_action :authenticate_user!,except: [:show]
  before_action :set_explore, only: [:show, :edit, :update, :destroy]

  # GET /explores
  # GET /explores.json
  def index
    @explores = Explore.all
    if params[:search]
      @categories = Category.all.verified.ransack(name_cont: params[:search].downcase).result
      guides = Guide.includes(:category,profile: :user).ransack(profile_user_firstname_or_profile_user_lastname_cont_any: params[:search]).result.uniq.exclude_user(current_user)
      explores = Explore.includes(:category,profile: :user).ransack(profile_user_firstname_or_profile_user_lastname_cont_any: params[:search]).result.uniq.exclude_user(current_user)
      @users = (guides + explores).uniq{|user| user.profile_id}
      @results = @categories + @users
    else
      @top_explores = ExploreRating.includes(profile: :user,explore: [:category]).rate_desc.where(explore_id: not_self_explore_category_ids).pluck(:explore_id).uniq.map{|x| Explore.find(x)}
      @popular_incountry = popular_merge(country,nil)
      @world_popular_explore_category = Category.joins(explores: :profile).verified.distinct_country(all_countries)
    end
  end

  # GET /explores/1
  # GET /explores/1.json
  def show
    @explore_ratings = ExploreRating.includes(guide: [profile: :user]).where(category:@explore.category,profile: @explore.profile).sort_by_created_desc
    @guide_ratings = GuideRating.includes(explore: [profile: :user]).where(category:@explore.category,profile: @explore.profile).sort_by_created_desc
    @set_ratings_array = @explore_ratings.to_a + @guide_ratings.to_a
    @all_ratings = @set_ratings_array.sort_by{|item| item.created_at}.reverse
    @projects =  Project.includes(:categories).where(profile:@explore.profile,categories:{id: @explore.category.id}).sort_by_created_desc

  end

  # GET /explores/new
  def new
    @explore = Explore.new
  end

  # GET /explores/1/edit
  def edit
  end

  # POST /explores
  # POST /explores.json
  def create
    @profile = current_user.profile

    if (params[:first_signup] == "true")
      #first signup explores update
      @list = @profile.explore_categories.uniq.select{|category| category.verified}.pluck(:id)
      @category = JSON.parse(params["exploreCategories"])["exp_categories"]
      # @categories_to_add = @selected_categories.reject{|x| @saved_categories.include? x.to_i}

      @add_cat = @category - @list
      @del_cat = @list - @category

      @add_cat.each do |x|
         @explore= Explore.new
         @explore.profile = @profile
         @explore.category = Category.find(x)
         @explore.save
       end
       @del_cat.each do |x|
         @profile.explore_categories.destroy(Category.find(x))
       end

       respond_to do |format|
         format.html { redirect_to '/profile/guides', success: 'Explores was successfully added.' }
         format.json { render :show, status: :ok, location: @profile }
       end

    else
      #edit categories from profile page
       @list = @profile.explore_categories.uniq.select{|category| category.verified}.pluck(:id)
       @category = JSON.parse(params["exploreCategories"])["exp_categories"]

       @add_cat = @category - @list
       @del_cat = @list - @category

       @add_cat.each do |x|
         @explore= Explore.new
         @explore.profile = @profile
         @explore.category = Category.find(x.to_i)
         @explore.save
       end

       @del_cat.each do |x|
         @profile.explore_categories.destroy(Category.find(x))
       end

      flash[:success] = "Explore was successfully created"
      redirect_to profiles_path
    end
  end

  def filter_result
    query_param = fetch_country_params(params)
    if params[:filter] == 'popular'
      @results=[]
      if params[:country].nil?
        @popular_incountry = popular_merge(country,nil)
        @world_popular_explore_category = Category.joins(explores: :profile).verified.distinct_country(all_countries)
      else
        @popular_incountry = popular_merge(params[:country],nil)
        @world_popular_explore_category = Category.joins(explores: :profile).verified.distinct_country(params[:country])
      end

    elsif params[:filter] == 'top'
      @results=[]
      if params[:country].nil?
        @results = ExploreRating.includes(profile: :user,explore: [:category]).rate_desc.where(explore_id: not_self_explore_category_ids).pluck(:explore_id).uniq.map{|x| Explore.find(x)}
      else
        @results = ExploreRating.includes(profile: :user,explore: [:category]).rate_desc.where(explore_id: not_self_explore_category_ids,:profiles=>query_param).pluck(:explore_id).uniq.map{|x| Explore.find(x)}
      end
      @top_name= top_category_explorer(@results)[:top_category_name]
      @top_category= top_category_explorer(@results)[:top_category_explore]
    elsif params[:filter] == 'most'
      if params[:country].nil?
        completed_session = Booking.where(:status=>2).pluck(:explore_id)
      else
        completed_session = Booking.includes(explore: :profile).where(:status=>2,:explores=>{:profiles=>query_param}).pluck(:explore_id)
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

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_explore
    @explore = Explore.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def explore_params
    params.permit(category:[])
  end

  def current_profile_id
    if current_user.profile
      current_user.profile.id
    end
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

  def self_explore_category_ids
    if current_user.profile
      Explore.where(profile: current_user.profile).pluck(:id)
    else
      []
    end
  end

  def not_self_explore_category_ids
    if current_user.profile
      category_ids_checked= current_user.profile.explores.pluck(:category_id)
      Explore.where(category_id: category_ids_checked).exclude_user(current_user).pluck(:id)
    else
      []
    end
  end

  def country
    if current_user.profile
      current_user.profile.country
    end
  end

end
