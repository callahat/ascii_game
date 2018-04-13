require 'active_support/concern'

# Found this trick from here: https://www.endpoint.com/blog/2016/02/22/devise-migration-legacy-rails-app
module UserAuthentication
  extend ActiveSupport::Concern

  included do

    def valid_password?(password)
      if !has_devise_password? && valid_transitional_password?(password)
        convert_password_to_devise(password)
        return true
      end

      super
    end

    def has_devise_password?
      encrypted_password.present?
    end

    def valid_transitional_password?(password)
      self.class.sha1(password) == passwd
    end

    def convert_password_to_devise(password)
      update!(password: password)
    end
  end
end
