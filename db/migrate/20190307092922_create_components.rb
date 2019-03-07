class CreateComponents < ActiveRecord::Migration[5.2]
  def change
    create_table :components do |t|
      t.string :name
      t.float :value
      t.float :minValue
      t.float :maxValue
      t.boolean :balance
      t.boolean :range
      t.boolean :residual
      t.belongs_to :composition
      
      t.timestamps
    end
  end
end
