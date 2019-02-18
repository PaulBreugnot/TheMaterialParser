class DatasheetCategory < ApplicationRecord
  has_many :datasheets, dependent: :delete_all
  mount_uploader :logo, CategoryLogoUploader # carrierwave file uploader

  validates :name, presence: true

end
