class CreateResponses < ActiveRecord::Migration
  def change
    create_table :responses do |t|
      t.text :url
      t.text :text
      t.text :hero

      t.timestamps null: false
    end
  end
end
