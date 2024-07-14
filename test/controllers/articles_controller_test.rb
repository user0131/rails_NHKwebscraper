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
    post articles_scrape_path, params: { url: "http://example.com/scrape-url" }
    assert_response :success
    assert_not_nil assigns(:articles)
  end
end

