class RenameDatasheetCategorieInDatasheetSelection < ActiveRecord::Migration[5.2]
  def change
    rename_column :datasheet_selections, :datasheet_categorie_id, :datasheet_category_id
  end
end
