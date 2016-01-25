class ResponseFinder
  def find(text)
    return Response.where(text: text)
  end
end
