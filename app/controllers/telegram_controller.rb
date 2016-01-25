class TelegramController < ApplicationController
  def response
    message = params[:message]
    chat_id = message[:chat][:id]
    found = ResponseFinder.new.find(message[:text]).to_a
    unless found.empty?
      hero_response = found.sample
      bot_message = {
        chat_id: chat_id,
        reply_to_message_id: message[:message_id],
        text: "#{hero_response[:hero]}: #{hero_response[:url]}"
      }
      Telegram.post("/sendMessage", query: bot_message)
    end
    head :ok, content_type: "text/html"
  end
end
