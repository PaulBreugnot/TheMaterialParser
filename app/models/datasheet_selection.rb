class DatasheetSelection < ApplicationRecord
  has_and_belongs_to_many :datasheets

  validates :selection_type, presence: true

end
