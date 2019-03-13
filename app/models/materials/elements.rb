require 'csv'

class AvailablePeriodicElements

  @@name_symbol_hash = {}
  @@symbol_name_hash = {}

  csv_path = File.join(File.dirname(__FILE__), "periodic_table.csv")
  csv_text = File.read(csv_path)
  @@table = CSV.parse(csv_text, headers: true)
  puts "Available periodic elements :"
  puts @@table.inspect
  @@table.by_row.each do |row|
    @@name_symbol_hash[row["Element"]] = row["Symbol"]
    @@symbol_name_hash[row["Symbol"]] = row["Element"]
  end

  def AvailablePeriodicElements.table
    @@table
  end

  def AvailablePeriodicElements.availableElementsBySymbols
    return @@symbol_name_hash
  end

  def AvailablePeriodicElements.checkElement(element)
    return @@name_symbol_hash[element] != nil || @@symbol_name_hash[element] != nil
  end

  def AvailablePeriodicElements.getSymbol(element)
    if @@name_symbol_hash[element] == nil && @@symbol_name_hash[element] == nil
      return nil
    elsif @@name_symbol_hash[element] != nil
      return @@name_symbol_hash[element]
    else
      return element
    end
  end

end
