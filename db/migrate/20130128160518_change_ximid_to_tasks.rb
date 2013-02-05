class ChangeXimidToTasks < ActiveRecord::Migration
  def up
  	    change_column :tasks, :xim_id, :string
  end

  def down
  end
end
