class BeforeSessionJob < ApplicationJob
  queue_as :default

  def perform(*args)
    booking = args[0]
    user = args[1]
    if booking.status == "upcoming"
      UserMailer.upcoming_session(booking,user).deliver_now
    end
  end
end
