class Users::ConfirmationsController < Devise::ConfirmationsController
  # def show
  #   @user = User.find_by(confirmation_token: params[:confirmation_token])
  #   if @user.nil?
  #     flash[:error] = "Ivalid token"
  #     redirect_to unauthenticated_root_path
  #   elsif !@user.confirmed_at.nil?
  #     flash[:notice] = "Email was already confirmed, please try signing in."
  #     redirect_to unauthenticated_root_path
  #   end
  # end

  private
  def after_confirmation_path_for(resource_name, resource)
    UserMailer.welcome_email(resource).deliver_later
    sign_in(resource) # In case you want to sign in the user
    flash[:success] = "Successfully signed up!!"
    first_page_introduction_path
  end
end
