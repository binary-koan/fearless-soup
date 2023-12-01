class CreateQuestions < ActiveRecord::Migration[7.1]
  def change
    create_table :questions do |t|
      t.text :question
      t.text :answer
      t.text :context

      t.timestamps
    end
  end
end
