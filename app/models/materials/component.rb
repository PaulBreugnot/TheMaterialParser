class Component < ApplicationRecord
  belongs_to :composition

  def self.isRawValueBalanced?(rawValue)
    return rawValue[/(Bal)|(bal)/] != nil
  end

  def self.isRawValueResidual?(rawValue)
    return rawValue[/≤|</] != nil
  end

  def self.extractValues(rawValue)
    return rawValue.scan(/\d+.\d+/)
  end
end
