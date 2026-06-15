# Rack middleware that protects the platform's public IP content (the public customer page and the
# Active Storage media/thumbnail proxy routes) from scraping: it blocks known AI/crawler User-Agents
# and rate-limits per IP. Only protected paths are inspected; everything else passes straight through.
class BotGuard
  PROTECTED_PATHS = %r{\A/(api/v1/public|rails/active_storage)/}

  DEFAULT_BOT_UA = Regexp.union(
    /GPTBot/i, /ChatGPT-User/i, /OAI-SearchBot/i, /ClaudeBot/i, /anthropic-ai/i, /Claude-Web/i,
    /CCBot/i, /Google-Extended/i, /Bytespider/i, /PerplexityBot/i, /Amazonbot/i, /Applebot-Extended/i,
    /Meta-ExternalAgent/i, /FacebookBot/i, /Diffbot/i, /Omgili/i, /ImagesiftBot/i, /DataForSeoBot/i,
    /cohere-ai/i, /YouBot/i, /magpie-crawler/i, /HTTrack/i,
    /bot|crawl|spider|scrap|slurp/i
  )

  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    return @app.call(env) unless request.path.match?(PROTECTED_PATHS)

    return forbidden if blocked_user_agent?(env["HTTP_USER_AGENT"])
    return too_many_requests if rate_limited?(request.ip)

    @app.call(env)
  end

  private

  def config
    Rails.application.config.x.bot_guard
  end

  def blocked_user_agent?(user_agent)
    (config.bot_user_agents || DEFAULT_BOT_UA).match?(user_agent.to_s)
  end

  def rate_limited?(ip)
    window = config.window
    key    = "botguard:#{ip}:#{Time.now.to_i / window}"

    count = Rails.cache.increment(key, 1, expires_in: window + 1)
    if count.nil?
      Rails.cache.write(key, 1, expires_in: window + 1, raw: true)
      count = 1
    end

    count.to_i > config.rate_limit
  end

  def forbidden
    json_response(403, { status: "fail", data: { base: [ "Forbidden" ] } })
  end

  def too_many_requests
    json_response(
      429,
      { status: "error", message: "Too many requests. Please try again later." },
      "Retry-After" => config.window.to_s
    )
  end

  def json_response(status, body, extra_headers = {})
    [ status, { "Content-Type" => "application/json" }.merge(extra_headers), [ body.to_json ] ]
  end
end
