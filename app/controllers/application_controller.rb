class ApplicationController < ActionController::API
  include ActionController::Cookies
  include Pagy::Method

  rescue_from ActiveRecord::RecordNotFound,        with: :not_found
  rescue_from ActiveRecord::RecordInvalid,         with: :record_invalid
  rescue_from ActionController::ParameterMissing,  with: :bad_request
  rescue_from ActionController::TooManyRequests,   with: :rate_limited

  around_action :switch_locale

  private

  # Resolve the request locale from the Accept-Language header so every response
  # (errors, validation messages and success messages) is returned in the client's
  # language. Falls back to the default locale when absent or unsupported.
  def switch_locale(&)
    I18n.with_locale(locale_from_header, &)
  end

  def locale_from_header
    tag = request.headers["Accept-Language"].to_s
            .split(",").first.to_s.split(";").first.to_s.split("-").first.to_s.downcase
    locale = tag.presence&.to_sym
    I18n.available_locales.include?(locale) ? locale : I18n.default_locale
  end

  def render_success(data = nil, status = :ok)
    @data = data
    render status: status
  end

  def render_fail(errors, status = :unprocessable_entity)
    render json: { status: "fail", data: errors }, status: status
  end

  def render_error(message, status = :internal_server_error)
    render json: { status: "error", message: message }, status: status
  end

  def not_found(_err)
    render_fail({ base: [ I18n.t("messages.errors.not_found") ] }, :not_found)
  end

  def record_invalid(err)
    render_fail(err.record.errors.as_json, :unprocessable_entity)
  end

  def bad_request(_err)
    render_fail({ base: [ I18n.t("messages.errors.bad_request") ] }, :bad_request)
  end

  def rate_limited
    render_error(I18n.t("messages.errors.too_many_requests"), :too_many_requests)
  end
end
