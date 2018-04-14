ActionMailer::Base.smtp_settings = {
   :address => "smtp.mailgun.org",
   :port => 2525,
   :domain => ENV["MAILGUN_SMTP_DOMAIN"],
   :authentication => :plain,
   :user_name => ENV["MAILGUN_SMTP_LOGIN"],
   :password => ENV["MAILGUN_SMTP_PASSWORD"],
   :enable_starttls_auto => true,
}
