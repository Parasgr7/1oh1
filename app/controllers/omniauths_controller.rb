class OmniauthsController < ApplicationController

  def googleAuth
    # Get access tokens from the google server
    access_token = request.env["omniauth.auth"]
    puts access_token
    user = User.from_omniauth(access_token)
    if user.id.nil?
      if user.save
        UserMailer.welcome_email(user).deliver_later
        session[:user_id] = user.id
        sign_in(user)
        flash[:success] = "Successfully signed up!!"
        resource.increment!(:sign_in_count)
        redirect_to '/profile/about-yourself'
      else
        redirect_to unauthenticated_root_path, error: "Error registering user!"
      end
    else
      session[:user_id] = user.id
      sign_in(user)
      redirect_to authenticated_root_path
    end
  end


  def facebookAuth
  end

end
