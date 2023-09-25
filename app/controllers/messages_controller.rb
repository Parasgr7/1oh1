class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_message, only: [:show, :edit, :update, :destroy]

  # GET /messages
  # GET /messages.json
  def index
    @mychats = current_user.chats.order(updated_at: :desc).map{|chat| chat.users.to_a.reject{|x| x.id == current_user.id}}.flatten.uniq{|x| x.id}
    @filterrific = initialize_filterrific(
      User.includes(:profile),
      params[:filterrific]
    ) or return
   @users = @filterrific.find.page(params[:page])
    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    message = Message.new(message_params)
    message.user = current_user
    timezone = Timezone[current_user.profile.time_zone]
    other_user = User.find_by_id(params[:message][:other_user].to_i)
    if !message[:content].empty? && message.save
          #broadcasting out to messages channel including the chat_id so messages are broadcasted to specific chat only
        ActionCable.server.broadcast( "messages_#{message_params[:chat_id]}",
        #message and user hold the data we render on the page using javascript
        message: message.content,
        user: message.user.firstname,
        other_user: params[:message][:other_user].to_i,
        user_id: message.user_id,
        current_user_id: current_user.id,
        time: timezone.utc_to_local(message.created_at).strftime("%l:%M") #NEED TO change according to ApplicationController (iff)
        )
        Notification.create(recipient: other_user, user: message.user, action: "message", notifiable: other_user, url: "#{user_chat_path(other_user,message.chat.slug, :other_user => current_user.id)}" )
        UserMailer.new_message(other_user, message.content, message.user).deliver_later
    else
        redirect_to user_chat_path
    end
  end

  private
      def message_params
        params.require(:message).permit(:content, :chat_id)
      end
end
