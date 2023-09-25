class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    if params[:search]
      @categories = Category.all.verified.ransack(name_cont: params[:search].downcase).result
      guides = Guide.includes(:category,profile: :user).ransack(profile_user_firstname_or_profile_user_lastname_cont_any: params[:search]).result.uniq.exclude_user(current_user)
      explores = Explore.includes(:category,profile: :user).ransack(profile_user_firstname_or_profile_user_lastname_cont_any: params[:search]).result.uniq.exclude_user(current_user)
      @users = (guides + explores).uniq{|user| user.profile_id}
      @results = @categories + @users
      puts @categories.size
      puts @users.size
    else
      @world_popular_explore_category = Category.verified.joins(explores: :profile).distinct_country(all_countries)
      @world_popular_guide_category = Category.verified.joins(guides: :profile).distinct_country(all_countries)
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
  end

  def filter_result
    if params[:state] && !params[:state].empty?
      if params[:city] && params[:state] && !params[:city].empty?
        query_param = {:country=>params[:country],:state=>params[:state],:city=>params[:city]}
      elsif params[:city].nil?
        query_param = {:country=>params[:country],:state=>params[:state]}
      elsif params[:city].empty? && params[:state]
        query_param = {:country=>params[:country],:state=>params[:state]}
      elsif params[:city] && params[:state].empty?
        query_param = {:country=>params[:country],:city=>params[:city]}
      end
    elsif params[:city] && params[:state].empty?
      if params[:city].empty?
        query_param = {:country=>params[:country]}
      else
        query_param = {:country=>params[:country],:city=>params[:city]}
      end
    else
      query_param = {:country=>params[:country]}
    end
    puts query_param
    if params[:filter] == 'popular'
      @results=[]
      if params[:country].nil?
        @world_popular_explore_category = Category.verified.joins(explores: :profile).distinct_country(all_countries)
        @world_popular_guide_category = Category.verified.joins(guides: :profile).distinct_country(all_countries)
      else
        @world_popular_explore_category = Category.verified.joins(explores: :profile).distinct_country(params[:country])
        @world_popular_guide_category = Category.verified.joins(guides: :profile).distinct_country(params[:country])
      end

    elsif params[:filter] == 'top'
      if params[:country].nil?
        @explore_results = ExploreRating.includes(profile: :user,explore: [:category]).rate_desc.where(explore_id: not_self_explore_category_ids).pluck(:explore_id).uniq.map{|x| Explore.find(x)}
        @guide_results = GuideRating.includes(profile: :user,explore: [:category]).rate_desc.where(guide_id: not_self_guide_category_ids).pluck(:guide_id).uniq.map{|x| Guide.find(x)}
      else
        @explore_results = ExploreRating.includes(profile: :user,explore: [:category]).rate_desc.where(explore_id: not_self_explore_category_ids,:profiles=>{:country=>params[:country]}).pluck(:explore_id).uniq.map{|x| Explore.find(x)}
        @guide_results = GuideRating.includes(profile: :user,explore: [:category]).rate_desc.where(guide_id: not_self_guide_category_ids,:profiles=>query_param).pluck(:guide_id).uniq.map{|x| Guide.find(x)}
      end
    elsif params[:filter] == 'most'
      @results=[]
      if params[:country].nil?
        completed_session_explore = Booking.where(:status=>2).pluck(:explore_id)
        completed_session_guide = Booking.where(:status=>2).pluck(:guide_id)
      else
        completed_session_explore = Booking.includes(explore: :profile).where(:status=>2,:explores=>{:profiles=>{country: params[:country]}}).pluck(:explore_id)
        completed_session_guide =Booking.includes(guide: :profile).where(:status=>2,:guides=>{:profiles=>query_param}).pluck(:guide_id)
      end

      self_explore = self_explore_category_ids
      self_guide = self_guide_category_ids
      most_explore = completed_session_explore - self_explore
      most_guide = completed_session_guide - self_guide

      @results_explore = most_explore.map{|x| Explore.find(x) if !Explore.where(id:x).exclude_user(current_user).empty?}.compact
      @results_guide = most_guide.map{|x| Guide.find(x) if !Guide.where(id:x).exclude_user(current_user).empty?}.compact
    else
    end
    @filter = params[:filter]
    respond_to do |format|
      format.js
    end
  end

  private
  def current_profile_id
    current_user.profile.id
  end

  def all_countries
    Profile.pluck(:country).uniq
  end

  def self_explore_category_ids
    if current_user.profile
      Explore.where(profile: current_user.profile).pluck(:id)
    else
      []
    end
  end

  def self_guide_category_ids
    if current_user.profile
      Guide.where(profile: current_user.profile).pluck(:id)
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

  def not_self_explore_category_ids
    if current_user.profile
      category_ids_checked= current_user.profile.explores.pluck(:category_id)
      Explore.where(category_id: category_ids_checked).exclude_user(current_user).pluck(:id)
    else
      []
    end
  end

end
