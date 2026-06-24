# Rack middleware that resolves the request locale from the Accept-Language header and wraps the
# whole downstream call in I18n.with_locale. Doing this in middleware (rather than an
# around_action) keeps the locale active during rescue_from rendering too — controller exception
# handlers (validation errors, not found, etc.) run after the action callbacks have unwound, so an
# around_action would have already restored the default locale before those responses are rendered.
class LocaleMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    I18n.with_locale(locale_from(env["HTTP_ACCEPT_LANGUAGE"])) do
      @app.call(env)
    end
  end

  private

  def locale_from(accept_language)
    tag = accept_language.to_s
            .split(",").first.to_s.split(";").first.to_s.split("-").first.to_s.downcase
    locale = tag.presence&.to_sym
    I18n.available_locales.include?(locale) ? locale : I18n.default_locale
  end
end
