require "net/http"

# LINE Messaging API のプッシュメッセージで運営者に通知を送る。
# credentials の line.channel_access_token / line.admin_user_id が未設定の場合は何もしない。
# 通知の失敗は呼び出し元の処理を妨げない(ログのみ)。
class LineNotifier
  PUSH_ENDPOINT = URI("https://api.line.me/v2/bot/message/push")
  OPEN_TIMEOUT = 3
  READ_TIMEOUT = 5

  def self.notify(text)
    token = Rails.application.credentials.dig(:line, :channel_access_token)
    to = Rails.application.credentials.dig(:line, :admin_user_id)
    if token.blank? || to.blank?
      Rails.logger.info "[LineNotifier] Skipped (line credentials not configured)"
      return false
    end

    http = Net::HTTP.new(PUSH_ENDPOINT.host, PUSH_ENDPOINT.port)
    http.use_ssl = true
    http.open_timeout = OPEN_TIMEOUT
    http.read_timeout = READ_TIMEOUT

    request = Net::HTTP::Post.new(PUSH_ENDPOINT.path)
    request["Authorization"] = "Bearer #{token}"
    request["Content-Type"] = "application/json"
    request.body = {
      to: to,
      messages: [ { type: "text", text: text } ]
    }.to_json

    response = http.request(request)
    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.error "[LineNotifier] Push failed: #{response.code} #{response.body}"
      return false
    end
    true
  rescue StandardError => e
    Rails.logger.error "[LineNotifier] Push error: #{e.class} #{e.message}"
    false
  end
end
