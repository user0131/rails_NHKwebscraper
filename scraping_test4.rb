require "selenium-webdriver"

d = Selenium::WebDriver.for :chrome 
text = []
d.get("https://www3.nhk.or.jp/news/word/0001539.html")
d.find_elements(:tag_name,"a").each do |u|
    text << u.text
end
p text
sleep 3