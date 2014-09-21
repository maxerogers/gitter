class AddShit < ActiveRecord::Migration
  def change
    add_column :languages, :hourly_count, :integer
  end
end
