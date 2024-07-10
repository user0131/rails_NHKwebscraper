require 'net/http'
require 'json'
require 'uri'

# ターゲットとなるURL
url = 'https://www3.nhk.or.jp/news/json16/word/0001539_001.json?_=1720541485092'

# URLからJSONデータを取得
uri = URI(url)
response = Net::HTTP.get(uri)
json_data = JSON.parse(response)


# 2番目のハッシュを取得
first_hash = json_data[0] if json_data.is_a?(Array) && json_data.size > 0

# ハッシュの中のハッシュの中の配列の中のハッシュから"title"キーの値を取得
if first_hash
  nested_array = first_hash['item'] 
  if nested_hash && nested_hash.is_a?(Hash)
    nested_array = nested_hash['nested_array_key'] # ここを実際のキー名に置き換えてください
    if nested_array && nested_array.is_a?(Array) && nested_array.size > 0
      title = nested_array[0]['title'] # ここを実際のキー名に置き換えてください
      puts "Title: #{title}"
    else
      puts "配列が存在しないか、要素がありません。"
    end
  else
    puts "ネストされたハッシュが存在しません。"
  end
else
  puts "2番目のハッシュが存在しません。"
end

#puts json_data
# 例: 'title'と'content'フィールドを抽出

#title = json_data['title']
#content = json_data['content']

# 抽出した情報を表示
#puts "Title: #{title}"
#puts "Content: #{content}"

# 必要に応じてJSON形式で保存
#data_dict = { 'title' => title, 'content' => content }
#File.open('extracted_data.json', 'w') do |f|
#  f.write(JSON.pretty_generate(data_dict))
#end
