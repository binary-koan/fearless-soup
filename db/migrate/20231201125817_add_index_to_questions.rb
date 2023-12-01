class AddIndexToQuestions < ActiveRecord::Migration[7.1]
  def change
    add_index :questions, :question, unique: true
  end
end
