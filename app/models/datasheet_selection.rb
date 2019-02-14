class DatasheetSelection < ApplicationRecord
  belongs_to :datasheet_category
  has_and_belongs_to_many :datasheets

  validates :selection_type, presence: true

end
