class Telegram
  include HTTParty
  base_uri "https://api.telegram.org/bot#{Rails.application.secrets[:telegram_token]}"

  def self.sendMessage message
    self.post "/sendMessage", body: message
  end

end
