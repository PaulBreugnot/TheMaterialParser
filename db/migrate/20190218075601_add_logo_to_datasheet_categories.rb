class AddLogoToDatasheetCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :datasheet_categories, :logo, :string
  end
end
