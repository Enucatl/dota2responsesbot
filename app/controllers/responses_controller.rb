class ResponsesController < ApplicationController
  def show
    @responses = ResponseFinder.new().find(params[:text])
    render json: @responses
  end
end
