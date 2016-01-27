require "rest-client"
require "secrets"

digitalocean = Secrets::Secret.new "config/digitalocean.yml"
secrets = Secrets::Secret.new "config/secrets.yml"

namespace :telegram do

  desc "set telegram webhook"
  task :set_webhook do
    host = digitalocean["digitalocean"]["droplet_ip"]
    system "scp dota2responsesbot@#{host}:~/dota2responsesbot/ssl/selfsigned.pem ."
    url = "https://api.telegram.org/bot#{secrets["production"]["telegram_token"]}/setWebHook"
    p url
    response = RestClient.post(
      url, {
        url: "https://#{host}/telegram",
        certificate: File.new("selfsigned.pem")
      }
    )
    p JSON.parse(response)
  end

end
