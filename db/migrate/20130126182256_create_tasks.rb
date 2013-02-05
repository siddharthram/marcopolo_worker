class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.integer :xim_id

      t.timestamps
    end
  end
end
