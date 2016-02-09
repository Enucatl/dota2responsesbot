require 'test_helper'

class TelegramControllerTest < ActionController::TestCase

  test "send a telegram message with no text" do
    post(:show, {
      message: {
        chat: {id: 62030274},
        message_id: 88
      }
    })
    assert @response.status == 200
  end

  test "should send a telegram message" do
    post(:show, {
      message: {
        chat: {id: 62030274},
        text: "oh, such strength is mine",
        message_id: 88
      }
    })
    assert JSON.parse(@response.body)["cached"] == "false"
  end

  test "should have a file_id from the previous test" do
    post(:show, {
      message: {
        chat: {id: 62030274},
        text: "oh, such strength is mine",
        message_id: 88
      }
    })
    post(:show, {
      message: {
        chat: {id: 62030274},
        text: "oh, such strength is mine",
        message_id: 88
      }
    })
    assert JSON.parse(@response.body)["cached"] == "true"
  end


end
