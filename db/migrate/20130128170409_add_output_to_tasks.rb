class AddOutputToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :output, :string
  end
end
