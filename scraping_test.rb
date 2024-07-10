require 'open-uri'
require 'nokogiri'

url = 'rawdata.html'

# urlにアクセスしてhtmlを取得する
html = URI.open(url).read
pp heroes_array
puts heroes_array.first['title']

