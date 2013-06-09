class AddColumn < ActiveRecord::Migration
  def up
add_column :tasks, :attachmentformat, :string
  end

  def down
  end
end
