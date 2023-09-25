json.slots do
  json.array! @slots
end
@container =[]
if !@slots.nil?
  @slots.each_with_index do |val,index|
    if @slots[index].nil? || @slots[index+1].nil?
      next
    elsif ((@slots[index+1].to_time-@slots[index].to_time).to_i/60).to_i == @slot_timing.to_i
      @container.push << [@slots[index],@slots[index+1]]
    end
  end
end
json.slots_distribution do
  #if case for fetching slots greater than current time with schedule time included
  if @date.to_date == (Time.zone.now).in_time_zone(@timeZone.name).to_date && !@schedule_time.nil?
    @container.select!{|x| x[0].to_datetime > ((Time.zone.now).in_time_zone(@timeZone.name) + @schedule_time.minutes) && x[0].to_datetime.in_time_zone(@front_end_time_zone) > ((Time.zone.now).to_datetime.in_time_zone(@front_end_time_zone) + @schedule_time.minutes)}
  end
  json.array! @container
end
json.count @container.size

# json.recurring do
#   json.range @range_first
# end
json.booking_unavail do
  json.range @arr
end
json.off_days @off_days
