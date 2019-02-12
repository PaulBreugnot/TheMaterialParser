class AddDatasheetToCategories < ActiveRecord::Migration[5.2]
  def change
    add_reference :datasheets, :datasheet_categorie, foreign_key: true
  end
end
