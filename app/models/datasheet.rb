class Datasheet < ApplicationRecord
  belongs_to :datasheet_category, required: false
  has_and_belongs_to_many :datasheet_selections
  mount_uploader :pdfDatasheet, PdfDatasheetUploader # Tells rails to use this uploader for this model.

  validates :name, presence: true # Make sure the owner's name is present.
  validates :pdfDatasheet, presence: true

end
