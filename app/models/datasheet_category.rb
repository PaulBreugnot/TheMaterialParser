class DatasheetCategory < ApplicationRecord
  has_many :datasheets
  validates :name, presence: true

end
