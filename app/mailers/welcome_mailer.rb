class WelcomeMailer < ActionMailer::Base
  default from: "ximly12@gmail.com"

  def welcome_email(user)
@user = user
mail(:to => user.email, :subject => "Welcome to Ximly!")
end
end
