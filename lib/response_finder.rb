class ResponseFinder

  def find(text)
    to_be_matched = text.downcase.gsub(/[^a-z]/, '')
    if blacklisted? to_be_matched
      Rails.logger.debug "response blacklisted"
      return []
    else
      return Response.where(match: to_be_matched)
    end
  end

  def blacklisted?(text)
    blacklist = [
      /^(ha)+$/,
      /^(ah)+$/,
    ]
    re = Regexp.union(blacklist)
    return re.match(text)
  end
  
end
