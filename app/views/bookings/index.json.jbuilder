json.array! @availabilities
json.array! @unavailabilities
json.array! @reservation_bookings do |booking|
  if booking.status != "completed"
    date_format = booking.all_day_booking? ? '%Y-%m-%d' : '%Y-%m-%dT%H:%M:%S'
    json.id booking.id
    json.title booking.title
    json.start local_time(booking.start.strftime(date_format),'%B %e, %Y %l:%M%P').to_time
    json.end local_time(booking.end.strftime(date_format),'%B %e, %Y %l:%M%P').to_time
    json.meta @meta

    if params["self"].to_i == 0 && params["other"].to_i == 1
      json.className 'pending'
      #Pending color for other user in reservation caldendar page
    elsif params["self"].to_i == 1 && params["other"].to_i == 0
        if params["explore_id"].nil? && params["guide_id"].nil? #This if statement is for personal_calendar
          if booking.status == "pending"
            json.className 'pending'
          elsif booking.status == "upcoming"
            if booking.guide.profile_id == @profile_id
              json.className 'guiding'
            elsif booking.explore.profile_id == @profile_id
              json.className 'exploring'
            end
          elsif booking.status == "unavailable"
            json.className 'unavailable'
          end
        else #this else is for reservation calendar
          json.className 'guiding'
          #Blue color for self user in reservation caldendar page
        end

    elsif params["self"].to_i == 1 && params["other"].to_i == 1
        if @meta[:common].include? booking.id
          json.className 'unavailable'
          #overlapping events for both
        elsif @meta[:other].include? booking.id
          json.className 'pending'
        else
          json.className 'guiding'
        end

    end
    json.extendedProps do
      json.update_url booking_path(booking, method: :patch)
      json.unavailable_url edit_calendar_path(booking)
      json.edit_url edit_booking_path(booking)
      json.delete_url booking_path(booking)
      json.eventDescription booking.description
    end
  end
end
