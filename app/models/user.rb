class User < ApplicationRecord


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

  def self.with_password(name, password)
    candidate = self.find_by_name(name)
    if candidate.present? && candidate.password_match(password)
        candidate
    else
      false
    end
  end

  def password_match(putative)
    puts 'testing pwd '+putative
    # todo: get salt, encrypt, compare BUT 1ST I need to build the data
    # fixme stub
    true
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
end
