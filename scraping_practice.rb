require 'nokogiri'
require 'open-uri'

def fetch_article_info(url)
  # URLからHTMLを取得
  html = URI.open(url)
  doc = Nokogiri::HTML(html)

  # タイトルを取得
  #title = doc.at_css('title').text

  # 記事の本文を取得（例として、'grid--col--single'クラスを持つ要素をターゲットにします）
  #article_body = doc.css('.grid--col--single').map(&:text).join("\n")
  article_body = doc.css('#main > article.module.module--list-items.word-result > section > div > div > ul > li> a').each do |anchor|
  puts anchor[:href]
  end
  # 結果を表示
  #puts "タイトル: #{title}"
  #puts "記事の本文:\n#{article_body}"
  #puts article_body
end

# 実行例
url = 'https://www3.nhk.or.jp/news/word/0001539.html'
fetch_article_info(url)