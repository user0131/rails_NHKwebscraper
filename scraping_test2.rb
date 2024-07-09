require 'nokogiri'
require 'open-uri'

def fetch_article_info(url)
  # URLからHTMLを取得
  html = URI.open(url)
  doc = Nokogiri::HTML(html)

  # タイトルを取得
  title = doc.at_css('title').text

  # 記事の本文を取得（例として、'article-body'クラスを持つ要素をターゲットにします）
  article_body = doc.css('.article-body').map(&:text).join("\n")

  # 結果を表示
  puts "タイトル: #{title}"
  puts "記事の本文:\n#{article_body}"
end

