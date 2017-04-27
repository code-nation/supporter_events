class AdministratorInvitation < ApplicationMailer

  def invite(email, password)
    @password = password
    mail(to: email, subject: ENV['ADMIN_INVITATION_SUBJECT'])
  end

end
