date_format = booking.all_day_booking? ? '%Y-%m-%d' : '%Y-%m-%dT%H:%M:%S'

json.id booking.id
json.title booking.title
json.start booking.start.strftime(date_format)
json.end booking.end.strftime(date_format)

json.allDay booking.all_day_booking? ? true : false

json.update_url booking_path(booking, method: :patch)
json.edit_url edit_booking_path(booking)
