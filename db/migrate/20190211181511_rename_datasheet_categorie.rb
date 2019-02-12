class RenameDatasheetCategorie < ActiveRecord::Migration[5.2]
  def change
    rename_column :datasheets, :datasheet_categorie_id, :datasheet_category_id
  end
end
