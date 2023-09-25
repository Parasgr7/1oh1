class MessageChannel < ApplicationCable::Channel
  def subscribed
    stream_from "messages_#{params[:chat_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  # def speak(data)
  #   # ActionCable.server.broadcast "message_channel", message: data['message']
  #   Message.create! content: data['message']
  # end
end
