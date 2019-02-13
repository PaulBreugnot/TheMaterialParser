class RenameDatasheetSelectionTypeColumn < ActiveRecord::Migration[5.2]
  def change
    change_table :datasheet_selections do |t|
      t.rename :type, :selection_type
    end
  end
end
