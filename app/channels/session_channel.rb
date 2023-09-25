class SessionChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    # stream_from "session_channel_#{id}"
    stream_from "session_channel_#{params[:session_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(data)
    puts(data)
  end
end
