class UserMailer < ApplicationMailer
  add_template_helper(ApplicationHelper)
  default from: 'no-reply@1oh1.org'
  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome to 1oh1 ')
  end

  def new_message(other_user,message,user)
    @user = user
    @message = message
    mail(to: other_user.email, subject: 'New message')
  end

  def running_late(companion_user,message, user)
    @user = user
    @message = message
    mail(to: companion_user.email, subject: 'Running Late')
  end

  def new_rating(user,rating,rated_by_user)
    @user = user
    @rated_by_user = rated_by_user
    @rating = rating
    if @rating.class.name == "ExploreRating"
      @type = "Explorer"
    elsif @rating.class.name == "GuideRating"
      @type = "Guide"
    end
    mail(to: @user.email, subject: 'New review')
  end

  def category_submission_received(user)
    @user = user
    mail(to: @user.email, subject: 'Category Review Submitted ')
  end

  def   category_submission_send_admin(user,category,from)
    @user = user
    @created_by = from
    @category = category
    mail(to: @user.email, subject: 'New Category Request ')
  end

  def category_submission_denied(user)
    @user = user
    mail(to: @user.email, subject: 'Category Submission Denied ')
  end

  def category_submission_approved(user, category)
    @user = user
    @category = category
    mail(to: @user.email, subject: 'Category Submission Approved ')
  end

  def booking_request_sent(booking)
    @booking = booking
    @client = Profile.find_by_id(booking.client_id).user
    @guide = Profile.find_by_id(booking.recipient_id).user
    @wallet = @client.profile.wallet.coins
    @timezone = @client.profile.time_zone
    @start_date_time = @booking.start.in_time_zone(@timezone)
    @end_date_time = @booking.end.in_time_zone(@timezone)
    @remaining = @wallet -  (@booking.coins.nil? ? 10 : @booking.coins)
    mail(to: @client.email, subject: 'Booking Request Sent ')
  end

  def booking_request_pending(booking)
    @booking = booking
    @client = Profile.find_by_id(booking.client_id).user
    @guide = Profile.find_by_id(booking.recipient_id).user
    @wallet = @guide.profile.wallet.coins
    @timezone = @guide.profile.time_zone
    @start_date_time = @booking.start.in_time_zone(@timezone)
    @end_date_time = @booking.end.in_time_zone(@timezone)
    @remaining = @wallet -  (@booking.coins.nil? ? 10 : @booking.coins)
    mail(to: @guide.email, subject: 'Booking Request Pending ')
  end

  def booking_request_declined_guide(booking,user,companion)
    @booking = booking
    @companion = companion
    @wallet = user.profile.wallet.coins
    @timezone = user.profile.time_zone
    @start_date_time = @booking.start.in_time_zone(@timezone)
    @end_date_time = @booking.end.in_time_zone(@timezone)
    @remaining = @wallet -  (@booking.coins.nil? ? 10 : @booking.coins)
    mail(to: user.email, subject: 'Booking Request Declined ')
  end

  def booking_request_declined_explore(booking,user,companion)
    @booking = booking
    @companion = companion
    @wallet = user.profile.wallet.coins
    @timezone = user.profile.time_zone
    @start_date_time = @booking.start.in_time_zone(@timezone)
    @end_date_time = @booking.end.in_time_zone(@timezone)
    @remaining = @wallet -  (@booking.coins.nil? ? 10 : @booking.coins)
    mail(to: user.email, subject: 'Booking Request Declined ')
  end

  def booking_request_approved_guide(booking)
    @booking = booking
    @client = Profile.find_by_id(booking.client_id).user
    @guide = Profile.find_by_id(booking.recipient_id).user
    @wallet = @guide.profile.wallet.coins
    @timezone = @guide.profile.time_zone
    @start_date_time = @booking.start.in_time_zone(@timezone)
    @end_date_time = @booking.end.in_time_zone(@timezone)
    @remaining = @wallet -  (@booking.coins.nil? ? 10 : @booking.coins)
    mail(to: @guide.email, subject: 'Booking Request Approved ')
  end

  def booking_request_approved_explore(booking)
    @booking = booking
    @client = Profile.find_by_id(booking.client_id).user
    @guide = Profile.find_by_id(booking.recipient_id).user
    @wallet = @client.profile.wallet.coins
    @timezone = @client.profile.time_zone
    @start_date_time = @booking.start.in_time_zone(@timezone)
    @end_date_time = @booking.end.in_time_zone(@timezone)
    @remaining = @wallet -  (@booking.coins.nil? ? 10 : @booking.coins)
    mail(to: @client.email, subject: 'Booking Request Approved ')
  end

  def upcoming_session(booking,user)
    @booking = booking
    @user = user
    arr = [booking.client_id ,booking.recipient_id]
    arr.delete(user.profile.id)
    @other_user = Profile.find_by_id(arr.first).user
    @timezone = user.profile.time_zone
    @start_date_time = @booking.start.in_time_zone(@timezone)
    @end_date_time = @booking.end.in_time_zone(@timezone)
    @wallet = user.profile.wallet.coins
    @remaining = @wallet -  (@booking.coins.nil? ? 10 : @booking.coins)
    mail(to: user.email, subject: 'Upcoming Session ')
  end

  def session_start(booking,url,user)
    @booking = booking
    @user = user
    @url = url
    arr = [booking.client_id ,booking.recipient_id]
    arr.delete(user.profile.id)
    @other_user = Profile.find_by_id(arr.first).user
    @timezone = user.profile.time_zone
    @start_date_time = @booking.start.in_time_zone(@timezone)
    @end_date_time = @booking.end.in_time_zone(@timezone)
    @wallet = user.profile.wallet.coins
    @remaining = @wallet -  (@booking.coins.nil? ? 10 : @booking.coins)
    mail(to: user.email, subject: 'Session Link ')
  end

  def confirmation_instructions(record, token, opts={})
    @user = record
    @token = token
    UserMailer.confirm_email(@user, @token).deliver_later
  end

  def confirm_email(record,token)
    @user = record
    @token = token
    mail(to: record.email, subject: 'Confirm Email Link ')
  end

  def daily_summary(user)
    mail(to: user.email, subject: 'Daily Summary ')
  end

  def reset_password(user)
    @user = user
    @token = user.reset_password_token
    mail(to: user.email, subject: 'Reset Password Link ')
  end

  def support_mail(contact)
    @contact = contact
    mail(to: "support@1oh1.org",from: contact.email, subject: 'Support Needed')
  end

end
