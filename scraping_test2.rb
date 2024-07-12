require 'selenium-webdriver'

# ChromeDriverのパスを指定
#driver: WebDriver = webdriver.Remote(
#  command_executor="http://localhost:4444/wd/hub", options=options
#  )
#driver_path = '/path/to/chromedriver' # 実際のパスに変更してください

# Chromeのオプションを設定
options = Selenium::WebDriver::Chrome::Options.new
options.add_argument('--headless')  # ヘッドレスモードで実行

# WebDriverのインスタンスを作成
driver = Selenium::WebDriver.for :chrome, options: options, driver_path: driver_path

# ターゲットとなるURLにアクセス
url = 'https://www3.nhk.or.jp/news/html/20240710/k10014507801000.html'
driver.get(url)

# 記事のタイトルを取得
title_element = driver.find_element(css: 'h1#news_title') # 正確なセレクタを指定
title = title_element.text

# 記事の本文を取得
content_elements = driver.find_elements(css: 'div#news_textbody p') # 正確なセレクタを指定
content = content_elements.map(&:text).join("\n")

# 結果を表示
puts "Title: #{title}"
puts "Content: #{content}"

# 必要に応じて抽出したデータをJSON形式で保存
data_dict = { 'title' => title, 'content' => content }
File.open('scraped_article.json', 'w') do |f|
  f.write(JSON.pretty_generate(data_dict))
end

# WebDriverを終了
driver.quit
