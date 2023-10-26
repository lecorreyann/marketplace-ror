class UserMailer < ApplicationMailer
  def email_validation
    @user = params[:user]
    @token = params[:token]
    mail(to: @user.email, subject: 'Email Validation') do |format|
      format.html
      format.text
    end
  end
end
