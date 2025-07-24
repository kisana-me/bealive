module OauthManagement
  # OAuth Management for ANYUR ver 1.0.0
  # controllers/oauth_controllerが必須

  OAUTH_REDIRECT_URI = Rails.env.development? ? "http://localhost:3000/callback" : "https://bealive.amiverse.net/callback"
  OAUTH_CLIENT_ID = "Be_Alive"
  OAUTH_CLIENT_SECRET = ENV["OAUTH_CLIENT_SECRET"]
  OAUTH_SCOPE =  "id name name_id subscription"

  require "net/http"

  def generate_authorize_url(state)
    "https://anyur.com/oauth/authorize?" + {
      response_type: "code",
      client_id: OAUTH_CLIENT_ID,
      redirect_uri: OAUTH_REDIRECT_URI,
      scope: OAUTH_SCOPE,
      state: state
    }.to_query
  end

  def exchange_code_for_token(code)
    token_response = Net::HTTP.post_form(
      URI("https://anyur.com/oauth/token"),
      {
        grant_type: "authorization_code",
        client_id: OAUTH_CLIENT_ID,
        client_secret: OAUTH_CLIENT_SECRET,
        redirect_uri: OAUTH_REDIRECT_URI,
        code: code
      }
    )
    unless token_response.is_a?(Net::HTTPSuccess)
      render plain: "OAuth token request failed: #{token_response.code} #{token_response.body}", status: :unauthorized
      return nil
    end
    JSON.parse(token_response.body)
  end

  def use_refresh_token(refresh_token)
    token_response = Net::HTTP.post_form(
      URI("https://anyur.com/oauth/token"),
      {
        grant_type: "refresh_token",
        client_id: OAUTH_CLIENT_ID,
        client_secret: OAUTH_CLIENT_SECRET,
        refresh_token: refresh_token
      }
    )
    unless token_response.is_a?(Net::HTTPSuccess)
      render plain: "OAuth token request failed: #{token_response.code} #{token_response.body}", status: :unauthorized
      return nil
    end
    JSON.parse(token_response.body)
  end

  def fetch_resources(access_token)
    info_uri = URI("https://anyur.com/api/resources")
    info_request = Net::HTTP::Post.new(info_uri)
    info_request["Authorization"] = "Bearer #{access_token}"
    info_request["Content-Type"] = "application/json"
    info_response = Net::HTTP.start(info_uri.hostname, info_uri.port, use_ssl: info_uri.scheme == "https") do |http|
      http.request(info_request)
    end
    unless info_response.is_a?(Net::HTTPSuccess)
      render plain: "Information request failed: #{info_response.code} #{info_response.body}", status: :unauthorized
      return nil
    end
    JSON.parse(info_response.body)
  end
end