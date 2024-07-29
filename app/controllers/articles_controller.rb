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

        content_element = wait.until { driver.find_element(xpath: '//*[@id="main"]/article/section/section/div') }
                                                                  #//*[@id="main"]/article[3]/section/section/div/p
                                                                  #//*[@id="main"]/article[3]/section/section/div/div/section/div/p
                                                                  #//*[@id="main"]/article[3]/section/section/div
        content = content_element.text

        begin
          summary = summarize_article(content)
          risk_score = assess_risk(content)
          puts "Summary: #{summary}, Risk Score: #{risk_score}" # ここで要約とリスクスコアを出力
        rescue StandardError => e
          puts "Error processing article: #{e.message}"
          summary = nil
          risk_score = nil
        end

        Article.create(title: title, time: time, content: content, summary: summary, risk_score: risk_score)
      end
    rescue Selenium::WebDriver::Error::NoSuchElementError => e
      puts "Error: #{e.message}"
    ensure
      driver.quit if driver
    end  
  end

  def summarize_article(article_text)
    require 'openai'
    puts "Calling OpenAI API for summarization..." # デバッグ用ログ
    @client = OpenAI::Client.new(access_token: 'sk-None-J96fOoSLvQvSNkAMjetIT3BlbkFJGOV0JSM57SoYRiM47c6w')
    response = @client.chat(
      parameters: {
        model: 'gpt-3.5-turbo',
        messages: [
          { role: 'system', content: 'あなたは優秀なAIアシスタントです。' },
          { role: 'user', content: "以下の記事を要約してください。ですます調を使ってください。：\n\n#{article_text}\n\n要約：" }
        ],
      }
    )
    puts response.inspect # ここでレスポンスの内容を出力

    if response && response['choices'] && response['choices'][0] && response['choices'][0]['message'] && response['choices'][0]['message']['content']
      response['choices'][0]['message']['content'].strip
    else
      puts "Invalid response format"
      nil
    end
  rescue StandardError => e
    puts "Error summarizing article: #{e.message}"
    nil
  end

  def assess_risk(article_text)
    require 'openai'
    puts "Calling OpenAI API for risk assessment..." # デバッグ用ログ
    @client = OpenAI::Client.new(access_token: 'sk-None-J96fOoSLvQvSNkAMjetIT3BlbkFJGOV0JSM57SoYRiM47c6w')
    response = @client.chat(
      parameters: {
        model: 'gpt-3.5-turbo',
        temperature: 0, 
        messages: [
          { role: 'system', content: 'あなたは優秀なAIアシスタントです。' },
          { role: 'user', content: "
         #要件
            - 以後の会話では、あなたはニュース記事のリスク判定BOTとして振る舞います
            - リスクは以下の5つの項目で評価されます。各項目は0から20のスコアを持ち、リスクスコアはその合計となります。
              - 被害範囲: 物理的な被害の広がりを示す。
                ex)
                  0～4: 被害が発生していない、または被害が非常に限られている（例: 一部の建物の破損）。
                  5～9: 市町村（例: 小規模な地域での停電や水害）。
                  10～14: 都道府県レベルでの被害（例: 大規模な洪水や地震による広範な被害）。
                  15～18: 国レベルでの被害（例: 国全体に影響を及ぼす自然災害や事故）。
                  19～20: 国際的な規模での被害（例: 大規模なパンデミックや戦争、国際的なテロ事件）。
              - 被害程度: 被害の深刻さを示す。アメリカ同時多発テロ事件のレベルを20。
                ex)
                  0～4: 被害が発生していない、または被害が軽微である（例: 軽微な物理的損害）。
                  5～9: 軽度の被害（例: 数件の軽傷や小規模な財産損失）。
                  10～14: 中程度の被害（例: 住宅やビルの一部損壊、数十人の負傷者）。
                  15～18: 大規模な被害（例: 複数のビル倒壊、大規模な火災、数百人の負傷者）。
                  19～20: 重大な被害（例: 大規模なテロ事件や自然災害で、多数の死傷者と巨額の損害）。
              - 社会的影響: 長期間・大規模な影響が出るものを20とする。
                ex)
                  0～4: 社会的影響がない、または非常に小さい（例: ローカルニュースとしての報道）。
                  5～9: 限定的な社会的影響（例: 一部の地域での騒動や不便）。
                  10～14: 中程度の社会的影響（例: 複数の都市での影響やニュースの注目）。
                  15～18: 広範な社会的影響（例: 国家規模での対応が必要な状況、重要な政策変更）。
                  19～20: グローバルな社会的影響（例: 世界的なパンデミックや国際的な経済危機）。
              - 死傷者: 数百人～数千人規模の事件は20。
                  ex)
                  0～4: 死亡者や負傷者がいない。
                  5～9: 少数の負傷者（例: 数人の軽傷）。
                  10～14: 中程度の死傷者数（例: 数十人の負傷者または少数の死亡者）。
                  15～18: 多数の死傷者（例: 数百人の負傷者、または複数の死亡者）。
                  19～20: 大規模な死傷者（例: 数千人規模の死亡者または負傷者）。
              - 被害金額: 数兆円規模の被害金額であれば20。
                ex)
                  0～4: 被害金額が0円、または非常に小さい。
                  5～9: 小規模な被害金額（例: 数百万円程度）。
                  10～14: 中程度の被害金額（例: 数億円程度）。
                  15～18: 大規模な被害金額（例: 数十億円程度）。
                  19～20: 巨額の被害金額（例: 数兆円規模の損失）。
                  
          ## 出力形式
            データは次の形式で返してください。
            
            リスクスコア:{(リスクスコア)}
            
          #例
            例えば、被害範囲の判定が10、被害程度の判定が8、社会的影響の判定が18、死傷者の判定が4、被害金額の判定が14だったら、リスクスコア=10+8+18+4+14=54となり出力は次のようになります

            リスクスコア:{54}

          それでは、以下の記事のリスクを0から100で評価してください。：\n\n#{article_text}" }
        ],
      }
    )

    puts "API response: #{response.inspect}" # レスポンス全体を出力

    if response && response['choices'] && response['choices'][0] && response['choices'][0]['message'] && response['choices'][0]['message']['content']
      content = response['choices'][0]['message']['content'].strip
      puts "Raw content received: #{content}" # 受信した内容の生データを出力

      # リスクスコアの行を抽出　
      if match = content.match(/リスクスコア[:：]\s*(\d+)/)
        risk_score = match[1].to_i
        puts "Extracted risk score: #{risk_score}" # 抽出されたリスクスコアを出力
        risk_score
      else
        puts "Risk score not found in the content"
        nil
      end
    else
      puts "Invalid response format"
      nil
    end
  rescue StandardError => e
    puts "Error assessing risk: #{e.message}"
    nil
  end

end