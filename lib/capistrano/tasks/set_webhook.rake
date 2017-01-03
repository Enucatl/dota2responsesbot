require "rest-client"
require "secrets"
require "logger"

logger = Logger.new STDOUT
RestClient.log = logger

digitalocean = Secrets::Secret.new "config/digitalocean.yml"
secrets = Secrets::Secret.new "config/secrets.yml"

namespace :telegram do

  desc "set telegram webhook"
  task :set_webhook do
    host = digitalocean["digitalocean"]["droplet_ip"]
    system "scp dota2responsesbot@#{host}:~/dota2responsesbot/ssl/selfsigned.pem ."
    url = "https://api.telegram.org/bot#{secrets["production"]["telegram_token"]}/setWebHook"
    destination = "https://#{host}/telegram"
    p url, destination
    response = RestClient.post(
      url, {
        url: destination,
        certificate: File.new("selfsigned.pem", "r"),
        multipart: true,
      }
    )
    p JSON.parse(response)
  end

  desc "test telegram webhook"
  task :test_webhook do
    host = digitalocean["digitalocean"]["droplet_ip"]
    destination = "https://#{host}/telegram"
    response = RestClient::Request.execute(
      url: destination,
      method: :post,
      ssl_ca_file: "selfsigned.pem",
      payload: {
        message: {
          chat: {id: 62030274},
          text: "hoho haha",
          message_id: 88
        }
      }
    )
    p response
  end

end
