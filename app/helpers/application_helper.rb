module ApplicationHelper
  include LocalTimeHelper

  def resource_name
    :user
  end

  def resource_class
    User
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def flash_class(level)
    case level
      when 'notice' then "alert-info"
      when 'success' then "alert-success"
      when 'error' then "alert-danger"
      when 'alert' then "alert-warning"
    end
  end

  def flash_icon(level)
    case level
      when 'notice' then "info"
      when 'success' then "check"
      when 'error' then "error"
      when 'alert' then "warning"
    end
  end

  def javascript(*files)
    content_for(:head) { javascript_include_tag(*files) }
  end

  def average_rating(user,category) #RATING AND OTHER VALUES FOR INDIVIDUAL PROFILE WITH CATEGORY OR WITHOUT CATEGORY [PROFILE PAGE]
    if !category.nil?
      explore_rating = ExploreRating.average_rating(user.profile,category.id)
      guide_rating = GuideRating.average_rating(user.profile,category.id)
    else
      explore_rating = ExploreRating.average_rating(user.profile,nil)
      guide_rating = GuideRating.average_rating(user.profile,nil)
    end
    explore_rate = explore_rating.average(:rating).to_f
    explore_count = explore_rating.size
    guide_rate = guide_rating.average(:rating).to_f
    guide_count = guide_rating.size
    group_explore_rating = group_rating(explore_rating.group_by(&:rating),explore_count)
    group_guide_rating = group_rating(guide_rating.group_by(&:rating),guide_count)
    group_all_rating = mesh_all(group_explore_rating,group_guide_rating)
    return {
            rating: explore_rate == 0 || guide_rate == 0 ? (explore_rate + guide_rate) : (explore_rate + guide_rate)/2,
            count: (explore_count+guide_count),
            explore_rating: explore_rate,
            explore_count: explore_count,
            guide_rating: guide_rate,
            guide_count: guide_count,
            pop_up_explore: group_explore_rating,
            pop_up_guide: group_guide_rating,
            pop_up_all: group_all_rating
          }
  end

  def group_rating(value_rating,count)
    #making hash for rating group wise
    hash = {1=>0,2=>0,3=>0,4=>0,5=>0}
    value_rating.each do |key,value|
      val = hash[key.to_i]
      hash[key.to_i] = val+value.length
    end
    #converting to percentage
    hash.each do |key,val|
      hash[key] = ((val.to_f/count)*100).nan? ? 0: ((val.to_f/count)*100).to_i
    end
    return hash
  end

  def mesh_all(explore_hash,guide_hash)
    list = explore_hash.map{|k,v| v == 0 || guide_hash[k]==0 ? (v + guide_hash[k]) : avg(guide_hash[k],v)}
    hash = {1=>0,2=>0,3=>0,4=>0,5=>0}
    list.each_with_index do |item,index|
      hash[index+1] = item
    end
    return hash
  end

  def avg(a,b)
    return (a+b)/2
  end

  def sparklines_yearly(collection)
    cluster = collection.from_this_month.group_by { |m| m.created_at.day}.map{|k,v| [k,v.size]}
    dummy = Array.new(Time.days_in_month(Time.now.month, Time.now.year), 0)
    cluster.each do |value|
       dummy[value[0]-1] = value[1]
    end
    dummy
  end

  def popular_merge(country,landing)
    popular_explore_category = Category.verified.joins(explores: :profile).distinct_country(country)
    popular_guide_category = Category.verified.joins(guides: :profile).distinct_country(country)
    popular = popular_explore_category.merge(popular_guide_category)
    if landing == true
      result = popular.sort_by { rand }.first(4)
    else
      result = popular
    end
    return result
  end

  def all_countries
    Profile.pluck(:country).uniq
  end

  def stats_count_category(category) #method to call for no. of explore_count.. with category [CATEGORIES PAGE]
    explore_count = Explore.with_category(category.id).exclude_user(current_user).uniq.size
    guide_count = Guide.with_category(category.id).exclude_user(current_user).uniq.size
    project_count = Project.includes(:categories).with_category(category.id).exclude_user(current_user).uniq.size
    sum_count = explore_count+guide_count+project_count
    return{
      explore_count: explore_count,
      guide_count: guide_count,
      project_count: project_count,
      sum_count: sum_count
    }
  end

  def stats_count_user(user,category) #method to call for no. of explore_count.. of user with respective category [EXPLORES & GUIDES PAGE]
    if user.nil?
      explore_count = Explore.where(category_id: category.id,profile: user.profile).uniq.size
      guide_count = Guide.where(category_id: category.id,profile: user.profile).uniq.size
      project_count = Project.includes(:categories).where(categories:{id: category.id},profile: user.profile).uniq.size
      sum_count = explore_count+guide_count+project_count
    else
      explore_count = user.profile.explore_categories.uniq.size
      guide_count = user.profile.guide_categories.uniq.size
      project_count = user.profile.projects.uniq.size
      sum_count = explore_count+guide_count+project_count
    end
    return{
      explore_count: explore_count,
      guide_count: guide_count,
      project_count: project_count,
      sum_count: sum_count
    }
  end

  def popular_categories
    list_ids = Ahoy::Event.where(name:"Category").group(:properties).order(count: :desc).size.keys
    return Category.verified.where(id: list_ids)
  end
  def popular_explorers
    list_ids = Ahoy::Event.where(name:"Explorer").group(:properties).order(count: :desc).size.keys.map{|x| Explore.find(x)}
    return Category.verified.where(id: list_ids)

  end
  def popular_guides
    list_ids = Ahoy::Event.where(name:"Guide").group(:properties).order(count: :desc).size.keys.map{|x| Guide.find(x)}
    return Category.verified.where(id: list_ids)
  end

  def find_chat(second_user)
    chats = current_user.chats.includes([:subscriptions,:messages])
    chats.each do |chat|
      chat.subscriptions.each do |s|
        if s.user_id == second_user.id
          return chat
        end
      end
    end
    nil
  end

  def profile_builder_complete
    profiles = current_user.profile.nil?
    if !current_user.profile.nil?
      explores = current_user.profile.explores.empty?
      guides = current_user.profile.guides.empty?
      projects = current_user.profile.projects.empty?
      availability = current_user.profile.availabilities.empty?
      all_empty_check =  availability
      result = {all_empty: all_empty_check,
                profile_nil: false}
    else
      result = {all_empty: true,
      profile_nil: true}
    end
    return result
  end


  def fetch_country_params(params)
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
    return query_param
  end

  def profile_photo(profile)
    profile.nil? ? image_path('profile.png') : profile.profile_photo.nil? || profile.profile_photo.empty? ? image_path('profile.png') : profile.profile_photo
  end

  def banner_photo(profile)
    profile.nil? ? image_path('banner.png') : profile.banner_photo.nil? || profile.banner_photo.empty? ? image_path('banner.png') : profile.banner_photo
  end

  def category_photo(category)
    category.nil? ? image_path('banner.png') : category.url.nil? || category.url.empty? ? image_path('banner.png') : category.url
  end

  def project_photo(project)
    project.nil? ? image_path('Section/workshop.jpg') : project.image.nil? || project.image.empty? ? image_path('Section/workshop.jpg') : project.image.first
  end

  def find_top_country(category)
    guides = category.guide_profiles.group(:country).count
    explores = category.explore_profiles.group(:country).count
    sorted_array = explores.merge(guides){|key,v1,v2| v1+v2}.sort_by {|k, v| -v}
    country = sorted_array[0].nil? ? "India": sorted_array[0][0]
    return country
  end

  def landing_stats
    return{
      explores_count:  Explore.all.size,
      guides_count:  Guide.all.size,
      projects_count:  Project.all.size,
    }
  end

  def format_availability(availabilities)
    if !availabilities.empty?
      hash={}
      availabilities.order(:week_day).each do |availability|
        start_time = availability.start_time.nil? ? nil : availability.start_time.strftime("%H:%M")
        end_time = availability.end_time.nil? ? nil : availability.end_time.strftime("%H:%M")
        hash[availability.week_day] = [start_time,end_time]
      end
      day_of_week_hash = Date::DAYNAMES.map.with_index{ |x, i| [i, x] }.to_h
      format_hash = {}
      hash.each.with_index do |x, i|
         time1 = x[1][0].nil? ? nil : x[1][0].to_datetime.strftime("%l:%M %p").strip
         puts time1
         a = time1.nil? ? time1 : (time1.slice! ":00")
         time2 = x[1][1].nil? ? nil : x[1][1].to_datetime.strftime("%l:%M %p").strip
         puts time2
         b = time2.nil? ? time2 : (time2.slice! ":00")
         format_hash[day_of_week_hash[x[0]]] = [time1,time2]
      end
      return format_hash
    else
      return {"Sunday"=>["9 AM", "5 PM"], "Monday"=>["9 AM", "5 PM"], "Tuesday"=>["9 AM", "5 PM"], "Wednesday"=>["9 AM", "5 PM"], "Thursday"=>["9 AM", "5 PM"], "Friday"=>["9 AM", "5 PM"], "Saturday"=>["9 AM", "5 PM"]}
    end
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    if title == "Start"
      title = "Time"
    elsif title == "Title"
      title = "Subject"
    end
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, {:sort => column, :direction => direction}, {:class => css_class}
  end


end
