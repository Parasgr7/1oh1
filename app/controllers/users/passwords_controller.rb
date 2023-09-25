class Users::PasswordsController < Devise::PasswordsController

  def create
    user = User.find_by(email: params["user"]["email"])
    if user.present?
      hashed_token = Devise.token_generator.generate(User, :reset_password_token)
      user.reset_password_token = hashed_token[1]
      user.reset_password_sent_at = Time.now.utc
      user.save!
      UserMailer.reset_password(user).deliver_later
      flash[:success] = "You will receive an email with instructions for resetting your password"
      redirect_to after_sending_reset_password_instructions_path_for(resource_name)
    else
      respond_to do |format|
        format.html { redirect_to unauthenticated_root_url, alert: 'User doesn\'t exists ' }
      end
    end
  end

  def update
    puts reset_params
    token = reset_params["reset_password_token"]
    @user = User.find_by(reset_password_token: token)
    if reset_params["password"] == reset_params["password_confirmation"]
      @user.update_attributes({password: reset_params["password"],reset_password_token: nil})
      sign_in(@user)
      redirect_to authenticated_root_path
    else
      flash.now[:error]= 'Both Passwords didn\'t match!!!'
      redirect_back(fallback_location: edit_user_password_path(@user, reset_password_token: token))
    end
  end

  protected
  def after_sending_reset_password_instructions_path_for(resource_name)
    unauthenticated_root_url
  end

  def after_resetting_password_path_for(resource)
    authenticated_root_path
  end

  private

  def reset_params
    params.require(:user).permit(:reset_password_token,:password,:password_confirmation)
  end

end
