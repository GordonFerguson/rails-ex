class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :string
      t.string :hashed_password
      t.string :string
      t.string :salt
      t.string :string
      t.string :email
      t.string :string

      t.timestamps
    end
  end
end
