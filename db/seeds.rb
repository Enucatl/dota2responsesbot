# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
#
#
heroes_filename = "db/heroes.json"
responses_filename = "db/dota_responses_1.3.json"

heroes = JSON.parse(File.read(heroes_filename))
responses = JSON.parse(File.read(responses_filename))

def short_hero_name_from_url(url)
  """Method that returns a short hero name for the given url
    (taken from the filename on the Wiki server)."""
  %r{/(\w+?)_.+?\.mp3}.match(url) do |search|
    if search[1] == 'Dlc'
      %r{/(Dlc_\w+?)_.+?\.mp3}.match(url) do |search_dlc|
        if search_dlc[1] == 'Dlc_tech'
          return 'Dlc_tech_ann'
        else
          return search_dlc[1]
        end
      end
    end
    return search[1]
  end
end

responses.each do |response, url|
  short_hero = short_hero_name_from_url url
  hero = heroes[short_hero]
  p hero
  Response.create(hero: hero, text: response, url: url, match: response.downcase.gsub(/[^a-z]/, ''))
end

p "Database created with #{Response.count} responses"
