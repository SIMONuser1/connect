module ApplicationHelper
  # def sign_up_business_check(user_business)
  #   unless @user_business.nil?
  #     welcome_path
  #     # render 'businesses/confirm_business_form', user_business: user_business
  #   else
  #     new_business_path
  #   end
  # end

  def display_avatar(user)
    if user.nil? || user.avatar_url.nil?
      image_tag('img/profilegrey.png', class: 'avatar avatar-xs')
    else
      cl_image_tag(user.avatar, class: 'avatar avatar-xs')
    end
  end
end
