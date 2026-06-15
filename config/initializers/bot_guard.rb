# Tunable settings for the BotGuard middleware (app/middleware/bot_guard.rb).
Rails.application.config.x.bot_guard.rate_limit = 300   # max requests per IP per window
Rails.application.config.x.bot_guard.window     = 60    # window length in seconds

# To override the blocked User-Agent list, set a Regexp here, e.g.:
#   Rails.application.config.x.bot_guard.bot_user_agents = /GPTBot|MyBot/i
# When left unset, BotGuard::DEFAULT_BOT_UA is used.
