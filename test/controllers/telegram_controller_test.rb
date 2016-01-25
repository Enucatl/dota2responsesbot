require 'test_helper'

class TelegramControllerTest < ActionController::TestCase

  test "should send a telegram message" do
    post(:show, {
      message: {
        chat: {id: 62030274},
        text: "oh, such strength is mine",
        message_id: 88
      }
    })
    assert @response.status == 200
  end

end
