class AccessRequestsMailer < ApplicationMailer

  def approval(admin_email, user_email, password)
    @password = password
    @user = User.find_by_email(user_email)
    mail(to: admin_email, subject: ENV['ADMIN_APPROVAL_SUBJECT'])
  end

  def approved(email, password)
    @password = password
    mail(to: email, subject: ENV['APPROVED_ACCESS_SUBJECT'])
  end

end
