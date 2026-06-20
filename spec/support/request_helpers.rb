module RequestHelpers
  def login_as(user)
    post '/api/v1/guest/session',
         params: { session: { email: user.email, password: user.password } },
         as: :json
  end

  def session_cookie
    cookies.signed[:session_token]
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :request
end
