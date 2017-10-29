class CreateApplicants < ActiveRecord::Migration
  def change
    create_table :applicants do |t|
      t.string :email
      t.integer :hired
      t.integer :stage
      t.belongs_to :batch, foreign_key: true

      t.timestamps null: false
    end
  end
end
