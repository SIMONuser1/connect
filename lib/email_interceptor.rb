# lib/email_interceptor.rb
class EmailInterceptor
  def self.delivering_email(message)
    # disabled for now
    # message.subject = "#{message.to} #{message.subject}"
    # message.to = [ 'jordan.moore@aiime.io' ]
  end
end

