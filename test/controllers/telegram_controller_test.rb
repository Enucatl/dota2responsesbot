require 'test_helper'

class TelegramControllerTest < ActionController::TestCase
  test "should send a telegram message" do
    post :response, {
      message: {
        chat: {id: 5664585},
        text: "oh, such strength is mine",
        message_id: 68507
      }
    }
    p JSON.parse(@response.body)
  end
end
