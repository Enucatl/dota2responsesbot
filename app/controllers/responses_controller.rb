class ResponsesController < ApplicationController
  def show
    @responses = Response.where(text: params[:text])
    render json: @responses
  end
end
