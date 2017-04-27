class ApplicationMailer < ActionMailer::Base
  default from: "#{ENV['APP_NAME']} <#{ENV['MAILER_SENDER']}>"

  layout 'mailer'
end
