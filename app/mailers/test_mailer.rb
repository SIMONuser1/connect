class TestMailer < ActionMailer::Base
  def message
    mail(
      :subject => 'Hello from Postmark',
      :to  => 'blake.rowley@aiime.io',
      :from => 'blake.rowley@aiime.io',
      :html_body => '<strong>Hello</strong> dear Postmark user.',
      :track_opens => 'true')
  end
end
