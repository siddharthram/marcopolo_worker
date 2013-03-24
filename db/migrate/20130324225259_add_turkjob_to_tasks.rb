class AddTurkjobToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :isturkjob, :boolean, default: false
  end
end
