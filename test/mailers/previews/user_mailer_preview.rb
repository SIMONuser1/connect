class UserMailerPreview < ActionMailer::Preview

  def welcome_email
    UserMailer.with(user: User.first).welcome_email
  end

  def confirmation_instructions
    UserMailer.confirmation_instructions(User.first, "faketoken", {})
  end

  def reset_password_instructions
    UserMailer.reset_password_instructions(User.first, "faketoken", {})
  end

  def unlock_instructions
    UserMailer.unlock_instructions(User.first, "faketoken", {})
  end
end
