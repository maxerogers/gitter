class Init < ActiveRecord::Migration
  def change
    create_table :user do |t|
      t.string :name
      t.integer :twitter_id
      t.string  :github_path
    end
  end
end
