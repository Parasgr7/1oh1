arr = []
json.guides @guide_history
json.explores @explore_history
json.markers do
  json.array! @bookings do |booking|
    if booking.guide.profile_id == current_profile.id
      type= "Guiding"
      companion = booking.explore.profile
      arr.push(CS.countries.key(booking.explore.profile.country).to_s)
    elsif booking.explore.profile_id == current_profile.id
      type= "Exploring"
      companion = booking.guide.profile
      arr.push(CS.countries.key(booking.guide.profile.country).to_s)
    end
    lat_long = []
    lat_long.push(companion.nil? ? nil: companion.latitude)
    lat_long.push(companion.nil? ? nil: companion.longitude)
    json.latLng lat_long
    json.name  companion.nil? ? nil: companion.user.full_name
    json.style do
      if type == "Guiding"
        json.fill '#e1bee7'
      else
        json.fill '#a5d6a7'
      end
    end
  end
end

json.region_values arr.uniq do |country|
  json.set! country, '100'
end
