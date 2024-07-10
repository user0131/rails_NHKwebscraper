require 'open-uri'
require 'nokogiri'

url = 'https://www3.nhk.or.jp/news/word/0001539.html'

# urlにアクセスしてhtmlを取得する
html = URI.open(url).read

# 取得したhtmlをNokogiriでパースする
doc = Nokogiri::HTML.parse(html)
pp doc

