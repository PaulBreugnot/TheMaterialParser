class AddDatasheetCategoryToDatasheetSelection < ActiveRecord::Migration[5.2]
  def change
    add_reference :datasheet_selections, :datasheet_categorie, foreign_key: true
  end
end
