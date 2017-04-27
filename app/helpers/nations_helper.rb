module NationsHelper
  def nb_get_token(code)
    client = nb_oauth_client
    token = client.auth_code.get_token(code, redirect_uri: nb_oauth_redirect_uri)
    token.token
  end

  def nb_authenticate_url
    client = nb_oauth_client
    client.auth_code.authorize_url(redirect_uri: nb_oauth_redirect_uri)
  end

  private
  def nb_oauth_client
    OAuth2::Client.new(ENV['OAUTH_CLIENT_ID'], ENV['OAUTH_CLIENT_SECRET'], site: "https://#{@nation.slug}.nationbuilder.com")
  end

  def nb_oauth_redirect_uri
    default_url_options = Rails.application.config.action_mailer.default_url_options

    case Rails.env
    when 'development'
      "http://#{default_url_options[:host]}#{':' + default_url_options[:port].to_s if default_url_options[:port]}#{ENV['OAUTH_REDIRECT_PATH']}"
    when 'production'
      "https://#{ENV['APP_DOMAIN']}" + "#{ENV['OAUTH_REDIRECT_PATH']}"
    end
    
  end
end
