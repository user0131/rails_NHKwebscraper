require 'net/http'
require 'json'
require 'uri'

# ターゲットとなるURL
url = 'https://www3.nhk.or.jp/news/json16/word/0001539_001.json?_=1720541485092'

# URLからJSONデータを取得
uri = URI(url)
response = Net::HTTP.get(uri)
json_data = JSON.parse(response)

# JSONデータの構造を確認（この行はデバッグ用です）
# puts JSON.pretty_generate(json_data)
# json_data = JSON.pretty_generate(json_data)
# 1番目のハッシュの中の"item"キーの値である配列の中の1番目のハッシュの中の"title"キーの値を取得
# ここではJSONデータの構造を仮定しています
titles = []
pubDates = []
links = []
first_hash = json_data.values.first # ハッシュの最初の値を取得
items_array = first_hash['item'] if first_hash.is_a?(Hash) # "item"キーの値である配列を取得
if items_array.is_a?(Array)
  items_array.each do |item|
    titles << item['title'] if item.is_a?(Hash) && item.key?('title')
    pubDates << item['pubDate'] if item.is_a?(Hash) && item.key?('pubDate')
    if item.is_a?(Hash) && item.key?('link')
      detail_url = 'https://www3.nhk.or.jp' + item['link']
      links << detail_url
    end
  end
end

# 取得した"title"の値を表示
puts "Titles: #{titles}"
puts "pubDates: #{pubDates}"
puts "links: #{links}"

# 必要に応じて抽出したタイトルをJSON形式で保存
# data_dict = { 'title' => title }
# File.open('extracted_title.json', 'w') do |f|
#  f.write(JSON.pretty_generate(data_dict))
# end
