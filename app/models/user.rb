# == Schema Information
# Schema version: 20110608123645
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  email              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  salt               :string(255)
#  encrypted_password :string(255)
#

class User < ActiveRecord::Base
  attr_accessor   :password
  # attr_accessible :email, :password
  
  before_save :encrypt_password
  
  email_regex     = /\S+@\S+\.\S+/i
  password_regex  = /^\S+$/i
  
  validates       :email,    :presence => true, 
                             :uniqueness => { :case_sensitive => false },
                             :format => { :with => email_regex }
  validates       :password, :presence => true,
                             :format => { :with => password_regex }
                             
  def self.authenticate(email, password)
    user = find_by_email(email)
    if user && user.password == BCrypt::Engine.hash_secret(password, user.salt)
      user
    else
      nil
    end
  end
                             
  def encrypt_password
    if password.present?
      self.salt = BCrypt::Engine.generate_salt
      self.password = BCrypt::Engine.hash_secret(password, salt)
    end
  end
end
