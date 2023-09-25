class ReviewsController < ApplicationController
  before_action :authenticate_user!


  def index
    if !params["explore_id"].nil? || !params["guide_id"].nil?
        @info = params["explore_id"] ? Explore.find(params["explore_id"].to_i) : Guide.find(params["guide_id"].to_i)
        @explore_ratings = ExploreRating.includes(guide: [profile: :user],explore: [:profile,:category]).where(category_id: @info.category_id,profile: current_profile)
        @guide_ratings = GuideRating.includes(guide: [profile: :user],explore: [:profile,:category]).where(category_id: @info.category_id,profile: current_profile)
    end

  end

  def create
    @booking = Booking.find(params[:booking_id])
    if @booking.guide.profile_id == current_profile.id
      @model = ExploreRating.new
      @model.profile = Profile.find(params["peer_id"])
    else
      @model = GuideRating.new
      @model.profile = Profile.find(params["peer_id"])
    end

    @model.guide = @booking.guide
    @model.explore = @booking.explore
    @model.rating = params[:rating]
    @model.review = params[:review]
    @model.category = @booking.explore.category

    @model.save!
    @booking.update(:status => 2,flag: true)
    Notification.create(recipient: @model.profile.user, user: current_user, action: "review", notifiable: @model, url: "/profiles" )
    UserMailer.new_rating(@model.profile.user,@model,current_user).deliver_later

    respond_to do |format|
      format.js
    end
  end

  def create_reviews
    if params[:Explore]
      @model = ExploreRating.new
      @model.explore = Explore.find(params[:Explore])
      @model.guide = Guide.where(category: @model.explore.category,profile: current_user.profile).first
      @model.category = @model.explore.category
      @model.profile = @model.explore.profile
    else
      @model = GuideRating.new
      @model.guide = Guide.find(params[:Guide])
      @model.explore = Explore.where(category: @model.guide.category,profile: current_user.profile).first
      @model.category = @model.guide.category
      @model.profile = @model.guide.profile
    end
    @model.review = params[:review]
    @model.rating = params[:rating]
    if @model.save
      flash.now[:success] = "Review Submitted!"
    else
      flash.now[:error] = "Add the category in your list!"
    end
    @flashing = flash
    Notification.create(recipient: @model.profile.user, user: current_user, action: "review", notifiable: @model, url: "/profiles" )
    respond_to do |format|
      format.js
    end
  end

  def edit_reviews
    id = params[:id].to_i
    if params[:explore_rating].present?
      @model = ExploreRating.find_by_id(id)

    elsif params[:guide_rating].present?
      @model = GuideRating.find_by_id(id)
    end
    if @model.update_attributes({rating: params[:rating],review: params[:review]})
      flash[:success] = "Review Updated!"
    else
      flash[:error] = "Add the category in your list!"
    end
    @flashing = flash
    respond_to do |format|
      format.js {render inline: "location.reload();" }
    end


  end

  def filter_reviews
    if params[:model]=="Explore"
      @model = Explore
    elsif params[:model]=="Guide"
      @model = Guide
    else
      @model = Profile
    end
    @record_object = @model.find(params[:id])
    @tab_name = params[:tab]
    if params[:filter]=="recent"
      if params[:model]=="profile"
        @explore_ratings  = ExploreRating.where(profile: @record_object).sort_by_created_desc
        @guide_ratings = GuideRating.where(profile: @record_object).sort_by_created_desc
      else
        @explore_ratings  = ExploreRating.where(category:@record_object.category,profile: @record_object.profile).sort_by_created_desc
        @guide_ratings = GuideRating.where(category:@record_object.category,profile: @record_object.profile).sort_by_created_desc
        @set_ratings_array = @explore_ratings.to_a + @guide_ratings.to_a
        @all_ratings = @set_ratings_array.sort_by{|item| item.created_at}.reverse
      end
    elsif params[:filter]=="highest"
      if params[:model]=="profile"
        @explore_ratings  = ExploreRating.where(profile: @record_object).rate_desc
        @guide_ratings = GuideRating.where(profile: @record_object).rate_desc
      else
        @explore_ratings  = ExploreRating.where(category:@record_object.category,profile: @record_object.profile).rate_desc
        @guide_ratings = GuideRating.where(category:@record_object.category,profile: @record_object.profile).rate_desc
        @set_ratings_array = @explore_ratings.to_a + @guide_ratings.to_a
        @all_ratings = @set_ratings_array.sort_by{|item| item.rating}.reverse
      end
    elsif params[:filter]=="lowest"
      if params[:model]=="profile"
        @explore_ratings  = ExploreRating.where(profile: @record_object).rate_asc
        @guide_ratings = GuideRating.where(profile: @record_object).rate_asc
      else
        @explore_ratings  = ExploreRating.where(category:@record_object.category,profile: @record_object.profile).rate_asc
        @guide_ratings = GuideRating.where(category:@record_object.category,profile: @record_object.profile).rate_asc
        @set_ratings_array = @explore_ratings.to_a + @guide_ratings.to_a
        @all_ratings = @set_ratings_array.sort_by{|item| item.rating}
      end
    elsif params[:filter]=="help"
      @projects =  Project.includes(:categories).where(profile:@record_object.profile,categories:{id: @record_object.category.id},help: true)
    elsif params[:filter]=="idea"
      @projects =  Project.includes(:categories).where(profile:@record_object.profile,categories:{id: @record_object.category.id},status:"idea")

    elsif params[:filter]=="progress"
      @projects =  Project.includes(:categories).where(profile:@record_object.profile,categories:{id: @record_object.category.id},status:"progress")

    elsif params[:filter]=="completed"
      @projects = Project.includes(:categories).where(profile:@record_object.profile,categories:{id: @record_object.category.id},status:"completed")
    elsif params[:filter]=="recent_project"
      @projects = Project.includes(:categories).where(profile:@record_object.profile,categories:{id: @record_object.category.id}).sort_by_created_desc
    end

    if @tab_name=="all"
      @div_name="all_tab_#{params[:model].downcase}"
      @ratings = @all_ratings
      @filtered_div = "filter_results_all_#{params[:model].downcase}"
    elsif @tab_name=="explore"
      @div_name="explorers_tab_#{params[:model].downcase}"
      @ratings = @explore_ratings
      @filtered_div = "filter_results_explorer_#{params[:model].downcase}"
    elsif @tab_name=="guide"
      @div_name="guides_tab_#{params[:model].downcase}"
      @ratings = @guide_ratings
      @filtered_div = "filter_results_guide_#{params[:model].downcase}"
    elsif @tab_name=="project"
      @div_name="projects_tab_#{params[:model].downcase}"
      @filtered_div = "filter_results_project_#{params[:model].downcase}"
    end
    respond_to do |format|
      format.js
    end
  end


  private

  def current_profile
    current_user.profile
  end
end
