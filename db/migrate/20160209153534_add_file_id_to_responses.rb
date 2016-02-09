class AddFileIdToResponses < ActiveRecord::Migration
  def change
    add_column :responses, :file_id, :string
  end
end
