class UserPreview < ActionMailer::Preview
  # Accessible from http://localhost:3000/rails/mailers/user/{function_name}
  def welcome_email
    UserMailer.welcome_email(User.first)
  end

  def new_message
    UserMailer.new_message(User.first,"ajhsak",User.second)
  end

  def new_rating
    UserMailer.new_rating(User.second,ExploreRating.last,User.first)
  end

  def running_late
    UserMailer.running_late(User.first,"ahsjahks",User.second)
  end

  def category_submission_received
    UserMailer.category_submission_received(User.first)
  end

  def   category_submission_send_admin
    UserMailer.category_submission_send_admin(User.first,Category.first,User.second)
  end

  def category_submission_denied
    UserMailer.category_submission_denied(User.first)
  end

  def booking_request_sent
    UserMailer.booking_request_sent(Booking.last)
  end

  def booking_request_pending
    UserMailer.booking_request_pending(Booking.last)
  end

  def booking_request_declined_guide
    UserMailer.booking_request_declined_guide(Booking.last,User.second,User.first)
  end

  def booking_request_declined_explore
    UserMailer.booking_request_declined_explore(Booking.last,User.first,User.second)
  end

  def booking_request_approved_guide
    UserMailer.booking_request_approved_guide(Booking.last)
  end

  def booking_request_approved_explore
    UserMailer.booking_request_approved_explore(Booking.last)
  end

  def category_submission_approved
    UserMailer.category_submission_approved(User.last, Category.last)
  end

  def upcoming_session
    UserMailer.upcoming_session(Booking.last,User.first)
  end

  def session_start
    UserMailer.session_start(Booking.last,"/dasas",User.second)
  end

  def confirm_email
    UserMailer.confirm_email(User.first)
  end

  def daily_summary
    UserMailer.daily_summary(User.first)
  end

  def reset_password
    UserMailer.reset_password(User.first)
  end

  def support_mail
    UserMailer.support_mail(Contact.last)
  end
end
