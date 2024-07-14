require "test_helper"

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get articles_path
    assert_response :success
  end

  test "should show article" do
    article = articles(:one)
    get article_path(article)
    assert_response :success
  end

  test "should scrape articles" do
    post scrape_articles_path, params: { url: "https://www3.nhk.or.jp/news/json16/word/0001539_001.json?_=1720541485092" }
    assert_response :success
    assert_not_nil assigns(:articles)
  end
end


