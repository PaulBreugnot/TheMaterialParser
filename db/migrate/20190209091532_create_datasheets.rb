class CreateDatasheets < ActiveRecord::Migration[5.2]
  def change
    create_table :datasheets do |t|
      t.string :name
      t.string :provider
      t.string :pdfDatasheet

      t.timestamps
    end
  end
end
