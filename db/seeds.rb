# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
#
#
responses_filename = "db/dota_responses_1.4.json"

responses = JSON.parse(File.read(responses_filename))
n = responses.length

responses.each_with_index do |r, i|
  p "creating response #{i} / #{n}"
  Response.create({
    hero: r["hero"],
    text: r["response"],
    url: r["url"],
    match: r["response"].downcase.gsub(/[^a-z]/, '')
  })

end

p "Database created with #{Response.count} responses"
