class Datasheet < ApplicationRecord
  belongs_to :datasheet_category, required: true
  has_and_belongs_to_many :datasheet_selections
  mount_uploader :pdfDatasheet, PdfDatasheetUploader # carrierwave file uploader

  validates :name, presence: true # Make sure the owner's name is present.
  validates :pdfDatasheet, presence: true

end
