class AddAskCountToQuestions < ActiveRecord::Migration[7.1]
  def change
    add_column :questions, :ask_count, :integer, default: 1
  end
end
