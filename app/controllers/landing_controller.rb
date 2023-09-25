class LandingController < ApplicationController
  # skip_before_action :authenticate_user!

  def index
    # @user_country = request.location.data["country_code"].nil? ? "India" : CS.get[request.location.data["country_code"].to_sym]

    @categories = Guide.pluck(:category_id).uniq.first(7).map{|x| Category.find(x)}

    # @popular_incountry = popular_merge(@user_country,true)

    @popular_inworld = popular_merge(all_countries,true)
    @top_guides = GuideRating.includes(profile: :user,explore: [:category]).rate_desc.pluck(:guide_id).uniq.map{|x| Guide.find(x)}
    @top_explores = ExploreRating.includes(profile: :user,explore: [:category]).rate_desc.pluck(:explore_id).uniq.map{|x| Explore.find(x)}
  end

  def terms
  end

  def policy
  end

  def search_result
    data = !params[:q].nil? ? params[:q].split(" ") : ""
    respond_to do |format|
      format.json{
        @categories = Category.verified.ransack(name_cont_any: data).result
        @guides = Guide.includes(:category,profile: :user).ransack(profile_user_firstname_or_profile_user_lastname_cont_any: data).result.uniq.exclude_user(current_user).pluck(:profile_id).uniq.map{|x| Profile.find_by_id(x)}
        @explores = Explore.includes(:category,profile: :user).ransack(profile_user_firstname_or_profile_user_lastname_cont_any: data).result.uniq.exclude_user(current_user).pluck(:profile_id).uniq.map{|x| Profile.find_by_id(x)}
        @projects = Project.includes(profile: :user).ransack(name_cont_any: data).result.exclude_user(current_user).uniq
        @users = (@guides + @explores).uniq{|user| user.id}

      }
    end
  end

  def user_login
    user = User.find_by(email: params[:email])
    render json: {url: user.nil? ? ActionController::Base.helpers.asset_path('profile.png') : user.profile.nil? ? ActionController::Base.helpers.asset_path('profile.png') : user.profile.profile_photo}
  end

  private
  def all_countries
    Profile.pluck(:country).uniq
  end
end
