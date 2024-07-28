require 'openai'

class OpenAIService
  def initialize
    @client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
  end

  def summarize_article(article_text)
    response = @client.completions(
      engine: "text-davinci-004",
      prompt: "以下の記事を要約してください：\n\n#{article_text}\n\n要約：",
      max_tokens: 150
    )
    response['choices'][0]['text'].strip
  end

  def assess_risk(article_text)
    response = @client.completions(
      engine: "text-davinci-004",
      prompt: "以下の記事のリスクスコアを1~100点で評価してください。被害範囲、被害程度、社会的影響、死傷者や被害金額の大きさを考慮してください：\n\n#{article_text}\n\nリスクスコア：",
      max_tokens: 10
    )
    response['choices'][0]['text'].strip.to_i
  end
end