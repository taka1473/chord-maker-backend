# 公開エンドポイントへのスパム・乱用対策。
# 単一 VM・単一プロセス構成のためカウンタはプロセス内メモリで十分。
Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

Rack::Attack.enabled = false if Rails.env.test?

# 問い合わせフォーム: 同一 IP から 1 時間に 5 件まで
Rack::Attack.throttle("contacts/ip", limit: 5, period: 1.hour) do |req|
  req.ip if req.post? && req.path == "/api/contacts"
end

Rack::Attack.throttled_responder = lambda do |_req|
  [ 429, { "Content-Type" => "application/json" },
    [ { error: "リクエストが多すぎます。しばらく時間をおいて再度お試しください。" }.to_json ] ]
end
