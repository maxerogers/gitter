class Init < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.integer :twitter_id
      t.string  :github_path
      t.string :twitter_token
      t.string :twitter_secret
    end
  end
end
