class CreateDatasheetSelections < ActiveRecord::Migration[5.2]
  def change
    create_table :datasheet_selections do |t|
      t.string :type
      t.boolean :saved

      t.timestamps
    end
  end
end
