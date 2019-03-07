class Composition < ApplicationRecord
  belongs_to :material
  has_many :components
  
end
