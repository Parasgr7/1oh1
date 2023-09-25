class StartSessionJob < ApplicationJob
  queue_as :default

  def perform(*args)
    booking = args[0]
    url = args[1]
    user = args[2]
    if booking.status == "upcoming"
      UserMailer.session_start(booking,url,user).deliver_now
    end
  end
end
