class CreateRepositories < ActiveRecord::Migration
  def self.up
    create_table :repositories do |t|
      t.column :name, :string
      t.column :path, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :repositories
  end
end
