# lib/tasks/scrape_articles.rake
require 'net/http'
require 'json'
require 'uri'
require 'selenium-webdriver'

namespace :scrape do
  desc "Scrape articles from NHK"
  task articles: :environment do
    # ターゲットとなるURL
    url = 'https://www3.nhk.or.jp/news/json16/word/0001539_001.json?_=1720541485092'
    
    # URLからJSONデータを取得
    uri = URI(url)
    response = Net::HTTP.get(uri)
    json_data = JSON.parse(response)
    
    #linkを格納するプログラム
    links = []
    first_hash = json_data.values.first # ハッシュの最初の値を取得
    items_array = first_hash['item'] if first_hash.is_a?(Hash) # "item"キーの値である配列を取得
    if items_array.is_a?(Array)
      items_array.take(3).each do |item|
        if item.is_a?(Hash) && item.key?('link')
          detail_url = 'https://www3.nhk.or.jp' + item['link']
          links << detail_url
        end
      end
    end
    
    
    # ChromeDriverのサービスを定義
    service = Selenium::WebDriver::Service.chrome(path: '/usr/local/bin/chromedriver')

    # Chromeのオプションを設定
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')  # ヘッドレスモードで実行
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')

    # WebDriverのインスタンスを作成
    driver = Selenium::WebDriver.for :chrome, options: options, service: service
    
    begin
      links.each do |link|
        driver.get(link)
        wait = Selenium::WebDriver::Wait.new(timeout: 30) # 最大30秒待機する

        # 記事のタイトルを取得/html/body/div[1]/div/div/main/article[3]/section/header/div/h1/span
        title_element = wait.until { driver.find_element(xpath: '//*[@id="main"]/article/section/header/div/h1/span') }
        title = title_element.text

        # 記事の投稿日時を取得
        time_element = wait.until { driver.find_element(xpath: '//*[@id="main"]/article/section/header/div/p/time') }
        time = time_element.text

        # 記事の本文を取得（最初の段落）
        content_element = wait.until { driver.find_element(xpath: '//*[@id="main"]/article/section/section/div/div/section/div/p') }
        content = content_element.text

        # データベースに保存
        Article.create(title: title, time: time, content: content)
      end
    rescue Selenium::WebDriver::Error::NoSuchElementError => e
      puts "Error: #{e.message}"
    ensure
      # WebDriverを終了
      driver.quit if driver
    end
  end
end