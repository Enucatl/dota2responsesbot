class ResponseFinder

  def find(text)
    to_be_matched = text.downcase.gsub(/[^a-z]/, '')
    return Response.where(match: to_be_matched)
  end

end
