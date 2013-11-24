class AddDocumentValidToTask < ActiveRecord::Migration
  def change
    add_column :tasks, :isvalid, :boolean
  end
end
