class CreateJoinTableDatasheetsDatasheetSelections < ActiveRecord::Migration[5.2]
  def change
    create_join_table :datasheets, :datasheet_selections do |t|
      # t.index [:datasheet_id, :datasheet_selection_id]
      t.index([:datasheet_selection_id, :datasheet_id], unique: true, name: "selection_index")
    end
  end
end
