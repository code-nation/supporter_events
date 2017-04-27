class SupportNotificationsMailer < ApplicationMailer

  def error_handler(event, error)
    @event = event
    @message = error['message']
    @error = error['validation_errors']

    mail(to: ENV['TECH_SUPPORT_EMAIL'], subject: "#{@event[:name]}: #{@message}")
  end
end