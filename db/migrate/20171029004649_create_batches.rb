class CreateBatches < ActiveRecord::Migration
  def change
    create_table :batches do |t|
      t.text :input
      t.text :output

      t.timestamps null: false
    end
  end
end
