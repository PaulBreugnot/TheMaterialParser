require 'csv'
require 'materials/component'
require 'materials/elements'

class Composition < ApplicationRecord
  belongs_to :material
  has_many :components

  def self.parseFromCsv(csv, orientation=:vertical)
    composition = Composition.new
    # composition.components = []
    puts "Parsing composition from csv..."
    puts csv

    if orientation==:vertical
      table = CSV.parse(csv, headers: true)
    else
      table = CSV.parse(csv)
    end

    table.by_col.each do |csvCol|
      puts "col : #{csvCol}"
      component = Component.new
      component.name = csvCol[0]
      if AvailablePeriodicElements.checkElement(component.name)
        puts "Component OK"
        component.name = AvailablePeriodicElements.getSymbol(component.name)
        component.balance = Component.isRawValueBalanced?(csvCol[1][0])
        component.residual = Component.isRawValueResidual?(csvCol[1][0])
        values = Component.extractValues(csvCol[1][0])
        if values.size > 0
          if values.size == 2
            component.range = true
            component.minValue = values[0].to_f
            component.maxValue = values[1].to_f
            component.value = (values[0].to_f + values[1].to_f) / 2
          elsif values.size == 1
            component.range = false
            component.value = values[0].to_f
          end
        end

        component.composition = composition
        composition.components.push(component)

        puts "Name : #{component.name}"
        puts "Value : #{component.value}"
        puts "MinValue : #{component.minValue}"
        puts "MaxValue : #{component.maxValue}"
        puts "Balance : #{component.balance}"
        puts "Residual : #{component.residual}"
      else
        # If at least one component was invalid, for now we consider that all the composition is invalid
        puts "Bad component detected"
        return nil
      end
    end

    return composition
  end
end
