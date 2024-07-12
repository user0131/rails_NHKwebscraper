require 'selenium-webdriver'

# ChromeDriverのサービスを定義
service = Selenium::WebDriver::Service.chrome(path: '/usr/local/bin/chromedriver')

# Chromeのオプションを設定
options = Selenium::WebDriver::Chrome::Options.new
options.add_argument('--headless')  # ヘッドレスモードで実行
options.add_argument('--no-sandbox')
options.add_argument('--disable-dev-shm-usage')

# WebDriverのインスタンスを作成
driver = Selenium::WebDriver.for :chrome, options: options, service: service

# ターゲットとなるURLにアクセス
url = 'https://www3.nhk.or.jp/news/html/20240710/k10014507801000.html'
driver.get(url)

# 記事のタイトルを取得
title_element = driver.find_element(xpath: '//*[@id="main"]/article[2]/section/header/div/h1/span')
title = title_element.text

# 記事の投稿日時を取得
time_element = driver.find_element(xpath: '//*[@id="main"]/article[2]/section/header/div/p/time')
time = time_element.text

# 記事の本文を取得（最初の段落）
content_element = driver.find_element(xpath: '//*[@id="main"]/article[2]/section/section/div/div/section/div/p[1]')
content = content_element.text

# 結果を表示
puts "Title: #{title}"
puts "Time: #{time}"
puts "Content: #{content}"

# データベースに保存
Article.create(title: title, content: content)

# 必要に応じて抽出したデータをJSON形式で保存
#data_dict = { 'title' => title, 'content' => content }
#File.open('scraped_article.json', 'w') do |f|
#  f.write(JSON.pretty_generate(data_dict))
#end

# WebDriverを終了
driver.quit
