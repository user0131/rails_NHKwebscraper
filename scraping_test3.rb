require 'open-uri'
require 'json'

heroes_json = URI.open('https://www3.nhk.or.jp/news/json16/word/0001539_001.json?_=1720541485092').read
heroes_array = JSON.parse(heroes_json)
pp heroes_array
pp heroes_array
puts heroes_array.first['title']