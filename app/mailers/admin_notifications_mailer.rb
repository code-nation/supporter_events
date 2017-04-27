class AdminNotificationsMailer < ApplicationMailer

  def event_created(admin_email, supporter, event)
  	@event_link = build_event_link(event['slug'])
  	@supporter_profile_link = build_supporter_profile_link(event['author_id'])
  	@admin_email = admin_email
  	@action_name = event['name']
  	@supporter = supporter['person']
  	@supporter_full_name = "#{@supporter['first_name']} #{@supporter['last_name']}"

  	mail(to: @admin_email, subject: ENV['EVENT_CREATED_ADMIN_NOTIFICATION_SUBJECT'])
  end

  private
  	def build_event_link(event_slug)
   		"https://#{ENV['PRIMARY_NATION_SLUG']}.nationbuilder.com/admin/sites/#{ENV['PRIMARY_NATION_SITE_ID']}/pages/search?q=#{event_slug}"
  	end

  	def build_supporter_profile_link(event_author_id)
  		"https://#{ENV['PRIMARY_NATION_SLUG']}.nationbuilder.com/admin/signups/#{event_author_id}/edit"
  	end
end
