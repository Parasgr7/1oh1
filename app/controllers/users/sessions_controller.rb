class Users::SessionsController < Devise::SessionsController

  def create
    @user = User.find_by(:email => params[:user][:email]) # you get the user now
    if @user.nil?
      respond_to do |format|
        format.js
      end
    else
      if @user.confirmed?
        self.resource = warden.authenticate(auth_options)
        if self.resource
          set_flash_message(:notice, :signed_in) if is_navigational_format?
          # flash[:success] = "Logged In"
          resource.increment!(:sign_in_count)
          sign_in(resource_name, resource)
          if !session[:return_to].blank?
            redirect_to session[:return_to]
            session[:return_to] = nil
          else
            redirect_to '/'
          end
        else
          # Authentication fails, redirect the user to the root page
          respond_to do |format|
            format.js
          end
        end
      else
        flash[:notice] = "You have to confirm your email address before continuing."
        @flashing = flash
        respond_to do |format|
          format.js
        end
      end
    end

  end


end
