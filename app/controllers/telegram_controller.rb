class TelegramController < ApplicationController

  def show
    message = params[:message]
    unless message.key?(:text)
      render json: {ok: "true"}
    end
    chat_id = message[:chat][:id]
    found = ResponseFinder.new.find(message[:text]).to_a
    unless found.empty?
      hero_response = found.sample
      logger.info hero_response
      if hero_response.file_id?
        # file already uploaded to telegram servers
        telegram_response = Telegramapi.new.send_voice(
          chat_id: chat_id,
          reply_to_message_id: message[:message_id],
          voice: hero_response.file_id
        )
        logger.info({cached: true, telegram: telegram_response})
        render json: {cached: "true"}
      else
        # need to upload a new file
        tmp_file = Tempfile.new(["voice-", ".ogg"], "tmp/ogg")
        command = "curl #{hero_response[:url]} | avconv -y -i - -map 0:a -codec:a opus -b:a 64k -vbr on #{tmp_file.path}"
        system command
        telegram_response = Telegramapi.new.send_voice(
          chat_id: chat_id,
          reply_to_message_id: message[:message_id],
          voice: tmp_file
        )
        tmp_file.unlink
        if telegram_response.key?(:result)
          hero_response.file_id = telegram_response["result"]["voice"]["file_id"]
          hero_response.save
        end
        logger.info({cached: false, telegram: telegram_response})
        render json: {cached: "false"}
      end
    end
  end

end
