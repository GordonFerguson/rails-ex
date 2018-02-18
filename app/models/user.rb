require 'digest'
class User < ApplicationRecord
  validates :name, :presence => true, :uniqueness => true
  validate :password_must_be_present

  # attr_accessor :password_confirmation
  attr_reader :password

  def User.encrypt_password(password,salt)
    Digest::SHA2.hexdigest(password+'wibble'+salt)
  end

  def User.with_password(name, pwd)
    if (user = find_by_name(name))
      if(user.hashed_password == encrypt_password(pwd,user.salt))
        user
      end
    end
  end

  def password=(pwd)
    @password = pwd
    if pwd.present?
      generate_salt
      self.hashed_password = self.class.encrypt_password(pwd,salt)
    end
  end


  def generate_salt
    self.salt = self.object_id.to_s + rand.to_s
  end

  # the roles, more access is later in the list
  def role_hierarchy
    [:visitor, :data_entry, :editor, :admin]
  end

  # a user may access their role and 'lower' levels as wll
  def role_allowed?(required_role)
    if role_hierarchy.find_index(required_role.to_sym)
      role_hierarchy.find_index(role.to_sym) >= role_hierarchy.find_index(required_role)
    else
      false
    end
  end


  # check for admin rights
  def is_admin
    test_access :admin
  end

  def is_editor
    test_access :editor
  end

  def is_data_entry
    test_access :data_entry
  end

private
  def password_must_be_present
    errors.add(:password,'Missing password') unless hashed_password.present?
  end

end
