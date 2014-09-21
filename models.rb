require 'bcrypt'
require 'sinatra/activerecord'

class User < ActiveRecord::Base
  include BCrypt

  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end
end

class Repo < ActiveRecord::Base
end
class Language < ActiveRecord::Base
end
