require "rest-client"
require "secrets"

digitalocean = Secrets::Secret.new "config/digitalocean.yml"
secrets = Secrets::Secret.new "config/secrets.yml"

namespace :telegram do

  desc "set telegram webhook"
  task :set_webhook do
    url = "https://api.telegram.org/bot#{secrets["production"]["telegram_token"]}/setWebHook?url=https://#{digitalocean["digitalocean"]["droplet_ip"]}:88/telegram"
    p url
    response = JSON.parse(RestClient.get(url))
    p response
  end

end
