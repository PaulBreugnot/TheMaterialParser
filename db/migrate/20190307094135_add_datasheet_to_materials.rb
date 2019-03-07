class AddDatasheetToMaterials < ActiveRecord::Migration[5.2]
  def change
    add_reference :datasheets, :material
  end
end
