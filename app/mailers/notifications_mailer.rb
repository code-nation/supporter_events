class NotificationsMailer < ApplicationMailer

  def event_created(supporter, event_slug)
	@supporter = supporter['person']
	@name = @supporter['first_name']
	
	mail(to: @supporter['email'], subject: ENV['EVENT_CREATED_AUTORESPONDER_SUBJECT'])
  end
end