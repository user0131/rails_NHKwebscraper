require 'open-uri'
require 'nokogiri'

# Webスクレイピングを行うサイトのURL
url = 'https://www3.nhk.or.jp/news/word/0001539.html'

# urlにアクセスしてhtmlを取得する
html = URI.open(url)

# 取得したhtmlをNokogiriでパースする
doc = Nokogiri::HTML(html)


doc.at_css('section.module--content ul')


