class CreateCompositions < ActiveRecord::Migration[5.2]
  def change
    create_table :compositions do |t|
      t.belongs_to :material, index: true
      t.timestamps
    end
  end
end
