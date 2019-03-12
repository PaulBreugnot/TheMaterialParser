class Material < ApplicationRecord
  has_one :composition, dependent: :destroy
  has_one :datasheet
end
