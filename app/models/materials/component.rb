class Component < ApplicationRecord
  belongs_to :composition

  def self.parseName(rawName)
    potentialNames = rawName.scan(/\w+/)
    potentialNames.each do |name|
      puts "name : #{name}"
      if AvailablePeriodicElements.getSymbol(name)
        return name
      end
    end
    return nil
  end

  def self.isRawValueBalanced?(rawValue)
    return rawValue[/(Bal)|(bal)|(Base)|(base)|>|≥/] != nil
  end

  def self.isRawValueResidual?(rawValue)
    return rawValue[/≤|<|-/] != nil
  end

  def self.extractValues(rawValue)
    return rawValue.scan(/\d+(?:\.\d+)*/)
  end
end
