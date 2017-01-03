require 'test_helper'

class ResponsesControllerTest < ActionController::TestCase

   test "find response" do
     text = "hoho, haha!"
     post :show, params: {text: text}
     p JSON.parse @response.body
     assert JSON.parse(@response.body)[0]["text"] == text
   end

   test "blacklisted response" do
     text = "hahahaha"
     post :show, params: {text: text}
     assert JSON.parse(@response.body) == []
   end

end
