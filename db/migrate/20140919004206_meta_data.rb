class MetaData < ActiveRecord::Migration
  def change
    create_table :repos do |t|
      t.string :github_path
      t.string :last_sha
      t.integer :lines
    end
    create_table :languages do |t|
      t.string :name
      t.integer :number_of_files
      t.integer :number_of_lines
      t.string :file_extensions
      #store as seperate by commas or try jsons. Look up String to array in ruby
      #example Ruby: .rb, .ru, .erb, .slim, .haml
    end

    add_column :users, :team_id, :integer
  end
end
