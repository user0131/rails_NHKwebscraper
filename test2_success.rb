require 'openai'

client = OpenAI::Client.new(access_token: '自分のopenaiapiキーをここに入力')

response = client.chat(
  parameters: {
    model: "gpt-3.5-turbo",
    messages: [
      { role: "user", content: "こんにちは" }
    ]
  }
)

puts response.dig("choices", 0, "message", "content")
