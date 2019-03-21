require 'csv'
require 'materials/component'
require 'materials/elements'

class Composition < ApplicationRecord
  belongs_to :material
  has_many :components, dependent: :destroy

  def self.parseFromCsv(csv, orientation=:vertical, headers=true)
    composition = Composition.new
    # composition.components = []
    puts "Parsing composition from csv..."
    puts csv

    table = CSV.parse(csv, headers: headers)
    table = CSV.parse(csv, headers: headers)

    if orientation==:vertical
      puts "Processing by column."
      data = table.by_col
    else
      puts "Processing by row."
      if headers
        data = table.by_row
      else
        data = table
      end
    end
    data.each do |entry|
      puts "entry : #{entry}"
      component = Component.new
      potentialName = Component.parseName(entry[0])
      if potentialName
        component.name = potentialName
        if orientation==:vertical
          value = entry[1][0]
        else
          value = entry[1]
        end
      # if AvailablePeriodicElements.checkElement(component.name)
        puts "Component name OK"
        component.name = AvailablePeriodicElements.getSymbol(component.name)
        if value
          puts "Component value OK"
          component.balance = Component.isRawValueBalanced?(value)
          component.residual = Component.isRawValueResidual?(value)
          values = Component.extractValues(value)
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
          puts "Bad component value detected"
          return nil
        end
      else
        # If at least one component was invalid, for now we consider that all the composition is invalid
        puts "Bad component name detected"
        return nil
      end
    end

    return composition
  end
end
