require 'test_helper'

class ResponsesControllerTest < ActionController::TestCase

   test "find Lion response" do
     text = "oh, such strength is mine"
     post :show, {text: text}
     assert JSON.parse(@response.body)[0]["text"] == text
   end

   test "blacklisted response" do
     text = "hahahaha"
     post :show, {text: text}
     assert JSON.parse(@response.body)[0]["text"] == text
   end


end
