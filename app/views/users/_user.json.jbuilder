json.extract! user, :id, :name, :string, :hashed_password, :string, :salt, :string, :email, :string, :created_at, :updated_at
json.url user_url(user, format: :json)
