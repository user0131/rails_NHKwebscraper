class ArticlesController < ApplicationController
  def index
  end

  def show
    @articles = Article.all
  end

  def scrape
    Article.destroy_all
    url = params[:url]
  
    if url == "https://www3.nhk.or.jp/news/word/0001539.html"
      url = "https://www3.nhk.or.jp/news/json16/word/0001539_001.json?_=1720541485092"
      scrape_articles(url)
      latest_article = Article.last
      redirect_to article_path(latest_article) if latest_article.present?
    else
      return
    end
  end
  

  private

  def scrape_articles(url)
    require 'net/http'
    require 'json'
    require 'uri'
    require 'selenium-webdriver'

    uri = URI(url)
    response = Net::HTTP.get(uri)
    json_data = JSON.parse(response)

    links = []
    first_hash = json_data.values.first
    items_array = first_hash['item'] if first_hash.is_a?(Hash)
    if items_array.is_a?(Array)
      items_array.take(3).each do |item|
        if item.is_a?(Hash) && item.key?('link')
          detail_url = 'https://www3.nhk.or.jp' + item['link']
          links << detail_url
        end
      end
    end


    service = Selenium::WebDriver::Service.chrome(
      path: '/app/.chromedriver/bin/chromedriver',
      port: 4444,
    )
    #development用→ service = Selenium::WebDriver::Service.chrome(path: '/usr/local/bin/chromedriver')

    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')

    driver = Selenium::WebDriver.for :chrome, options: options, service: service

    begin
      links.each do |link|
        driver.get(link)
        wait = Selenium::WebDriver::Wait.new(timeout: 30)

        title_element = wait.until { driver.find_element(xpath: '//*[@id="main"]/article/section/header/div/h1/span') }
        title = title_element.text

        time_element = wait.until { driver.find_element(xpath: '//*[@id="main"]/article/section/header/div/p/time') }
        time = time_element.text

        content_element = wait.until { driver.find_element(xpath: '//*[@id="main"]/article/section/section/div/div/section/div/p') }
        content = content_element.text

        Article.create(title: title, time: time, content: content)
      end
    rescue Selenium::WebDriver::Error::NoSuchElementError => e
      puts "Error: #{e.message}"
    ensure
      driver.quit if driver
    end  
  end
end
