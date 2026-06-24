require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Rack middleware referenced while building the stack at boot — required eagerly and kept out of
# the Zeitwerk autoloader (see the `middleware` ignore on autoload_lib below).
require_relative "../lib/middleware/bot_guard"
require_relative "../lib/middleware/locale_middleware"

module KondangyukApi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks middleware])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Internationalization — the front-end supports Indonesian and English. The request locale is
    # resolved from the Accept-Language header by LocaleMiddleware (see below), falling back to :en
    # when absent or unsupported.
    config.i18n.available_locales = [ :en, :id ]
    config.i18n.default_locale = :en
    config.i18n.fallbacks = [ :en ]

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # Enable cookie support for the httpOnly signed session_token cookie. Only ActionDispatch::Cookies
    # is needed (it powers cookies.signed via secret_key_base); the Rails session store is not used —
    # authentication is token-based, not session[]-based.
    config.middleware.use ActionDispatch::Cookies

    # Serve Active Storage files through stable, non-expiring proxy URLs so media
    # referenced inside documents stays shareable (public customer pages, snapshots).
    config.active_storage.resolve_model_to_route = :rails_storage_proxy

    # Keep the API's IP content (documents + media) out of search engines and AI
    # training crawlers on every response, including Active Storage.
    config.action_dispatch.default_headers = config.action_dispatch.default_headers.merge(
      "X-Robots-Tag" => "noindex, nofollow, noai, noimageindex"
    )

    # Rate-limit and block scraper/AI bots on public + asset routes (see lib/middleware/bot_guard.rb).
    config.middleware.use BotGuard

    # Resolve the request locale from Accept-Language and keep it active for the whole request,
    # including rescue_from rendering. Inserted before BotGuard so even BotGuard's own responses are
    # localized (see lib/middleware/locale_middleware.rb).
    config.middleware.insert_before BotGuard, LocaleMiddleware
  end
end
