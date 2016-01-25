class Telegram
  include HTTParty
  base_uri = "https://api.telegram.org/bot#{Rails.application.secrets[:telegram_token]}"
end
