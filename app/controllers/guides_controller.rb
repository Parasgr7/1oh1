class GuidesController < ApplicationController
  before_action :authenticate_user!,except: [:show]
  before_action :set_guide, only: [:show, :edit, :update, :destroy]

  # GET /guides
  # GET /guides.json
  def index
    @guides = Guide.all
    if guide_params[:search]
      @categories = Category.all.verified.ransack(name_cont: params[:search].downcase).result
      guides = Guide.includes(:category,profile: :user).ransack(profile_user_firstname_or_profile_user_lastname_cont_any: params[:search]).result.uniq.exclude_user(current_user)
      explores = Explore.includes(:category,profile: :user).ransack(profile_user_firstname_or_profile_user_lastname_cont_any: params[:search]).result.uniq.exclude_user(current_user)
      @users = (guides + explores).uniq{|user| user.profile_id}
      @results = @categories + @users
    else
      @top_guides = GuideRating.rate_desc.where(guide_id: not_self_guide_category_ids).pluck(:guide_id).uniq.map{|x| Guide.find(x)}
      @popular_incountry = popular_merge(country,nil)
      @world_popular_guide_category= Category.joins(guides: :profile).verified.distinct_country(all_countries)

      if !@top_guides.empty?
        @first_category = @top_guides[0].category
        @first_category_name_guide = @first_category.name
        @first_category_guide= @guides.includes(:category,profile: :user).where(:category_id => @first_category.id).where.not(:profile_id => current_profile_id).sort_by_created_desc
      else
        @first_category_name_guide = "None"
        @first_category_guide = []
      end
    end
  end

  # GET /guides/1
  # GET /guides/1.json
  def show
    @explore_ratings = ExploreRating.where(category:@guide.category,profile: @guide.profile).sort_by_created_desc
    @guide_ratings = GuideRating.where(category:@guide.category,profile: @guide.profile).sort_by_created_desc
    @set_ratings_array = @explore_ratings.to_a + @guide_ratings.to_a
    @all_ratings = @set_ratings_array.sort_by{|item| item.created_at}.reverse
    @projects =  Project.includes(:categories).where(profile:@guide.profile,categories:{id: @guide.category.id}).sort_by_created_desc

  end

  # GET /guides/new
  def new
    @guide = Guide.new
  end

  # GET /guides/1/edit
  def edit
  end

  # POST /guides
  # POST /guides.json
  def create
    @profile = current_user.profile
    @saved_categories = @profile.guide_categories.uniq.select{|category| category.verified}.pluck(:id)

    if params[:first_signup] == "true"
      #first signup explores update
      # @selected_categories = JSON.parse(params["guideCategories"])["categories"]
      # @categories_to_add = @selected_categories.reject{|x| @saved_categories.include? x.to_i}
      @listg = @profile.guide_categories.uniq.select{|category| category.verified}.pluck(:id)
      @category = JSON.parse(params["guideCategories"])["guid_categories"]
      @add_cat = @category - @listg
      @del_cat = @listg - @category

        @add_cat.each do |x|
         @guide= Guide.new
         @guide.profile = @profile
         @guide.category = Category.find(x)
         @guide.save
        end

       @del_cat.each do |x|
         @profile.guide_categories.destroy(Category.find(x))
       end

       respond_to do |format|
         format.html { redirect_to '/profile/projects', success: 'Guides was successfully added.' }
         format.json { render :show, status: :ok, location: @profile }
       end
    else
      if @profile.nil?
        redirect_to profiles_path, notice: 'Please update about your yourself'
      else
        @listg = @profile.guide_categories.uniq.select{|category| category.verified}.pluck(:id)
        @category = JSON.parse(params["guideCategories"])["guid_categories"]

        @add_cat = @category - @listg
        @del_cat = @listg - @category

        @add_cat.each do |x|
          @explore= Guide.new
          @explore.profile = @profile
          @explore.category = Category.find(x.to_i)
          @explore.save
        end

        @del_cat.each do |x|
          @profile.guide_categories.destroy(Category.find(x))
        end
         flash[:success] = "Guide was successfully created."
        redirect_to profiles_path
      end
    end

  end

  def filter_result
    query_param = fetch_country_params(params)

    if params[:filter] == 'popular'
      @results=[]
      if params[:country].nil?
        @popular_incountry = popular_merge(country,nil)
        @world_popular_guide_category = Category.joins(guides: :profile).verified.distinct_country(all_countries)
      else
        @popular_incountry = popular_merge(params[:country],nil)
        @world_popular_guide_category = Category.joins(guides: :profile).verified.distinct_country(params[:country])
      end

    elsif params[:filter] == 'top'
      @results=[]
      if params[:country].nil?
        @results = GuideRating.includes(profile: :user,explore: [:category]).rate_desc.where(explore_id: not_self_guide_category_ids).pluck(:explore_id).uniq.map{|x| Guide.find(x)}
      else
        @results = GuideRating.includes(profile: :user,explore: [:category]).rate_desc.where(explore_id: not_self_guide_category_ids,:profiles=>query_param).pluck(:explore_id).uniq.map{|x| Guide.find(x)}
      end
      @top_name= top_category_guide(@results)[:top_category_name]
      @top_category= top_category_guide(@results)[:top_category_guide]
    elsif params[:filter] == 'most'
      if params[:country].nil?
        completed_session = Booking.where(:status=>2).pluck(:guide_id)
      else
        completed_session = Booking.includes(guide: :profile).where(:status=>2,:guides=>{:profiles=>query_param}).pluck(:guide_id)
      end
      self_guide = self_guide_category_ids
      most = completed_session - self_guide
      @results = most.map{|x| Guide.find(x) if !Guide.where(id:x).exclude_user(current_user).empty?}.compact
    end
    @filter = params[:filter]
    respond_to do |format|
      format.js
    end

  end

  private
    def set_guide
      @guide = Guide.find(params[:id])
    end

    def guide_params
      params.permit(:search,category:[])
    end
    def current_profile_id
      if current_user.profile
        current_user.profile.id
      end
    end

    def self_guide_category_ids
      if current_user.profile
        Guide.where(profile: current_user.profile).pluck(:id)
      else
        []
      end
    end

    def top_category_guide(top_guides)
      guides = Guide.all
      if !top_guides.empty?
        category = top_guides[0].category
        @first_category_name_guide =  category.name
        @first_category_guide = guides.includes(:category,profile: :user).where(:category_id => category.id).exclude_user(current_user)
      else
        @first_category_name_explore = "None"
        @first_category_explore = []
      end
      return {
        top_category_name: @first_category_name_guide,
        top_category_guide: @first_category_guide
      }
    end

    def not_self_guide_category_ids
      if current_user.profile
        guide_ids_checked = current_user.profile.guides.pluck(:category_id).uniq
        Guide.where(category_id: guide_ids_checked).exclude_user(current_user).pluck(:id)
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
