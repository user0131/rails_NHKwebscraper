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
    
    # 記事の詳細ページのリンクを取得
    links = []
    first_hash = json_data.values.first
    items_array = first_hash['item'] if first_hash.is_a?(Hash)
    
    if items_array.is_a?(Array)
      items_array.each do |item|
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

        # 記事のタイトルを取得
        title_element = driver.find_element(xpath: '//*[@id="main"]/article[2]/section/header/div/h1/span')
        title = title_element.text

        # 記事の投稿日時を取得
        time_element = driver.find_element(xpath: '//*[@id="main"]/article[2]/section/header/div/p/time')
        time = time_element.text

        # 記事の本文を取得（最初の段落）
        content_element = driver.find_element(xpath: '//*[@id="main"]/article[2]/section/section/div/div/section/div/p[1]')
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
