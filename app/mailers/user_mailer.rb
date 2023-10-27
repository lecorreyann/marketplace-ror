class UserMailer < ApplicationMailer
  def email_validation
    @user = params[:user]
    @token = params[:token]
    mail(to: @user.email, subject: 'Email Validation') do |format|
      format.html
      format.text
    end
  end

  def reset_password
    @user = params[:user]
    @token = params[:token]
    mail(to: @user.email, subject: 'Reset Password') do |format|
      format.html
      format.text
    end
  end
end
