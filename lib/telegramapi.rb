require "telegram/bot"

class Telegramapi < Telegram::Bot::Api

  def initialize
    super(Rails.application.secrets[:telegram_token])
  end

end
