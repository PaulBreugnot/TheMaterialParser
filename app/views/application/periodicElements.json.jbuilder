json.periodic_elements @periodicElements.each_key do |symbol|
  json.symbol symbol
  json.name @periodicElements[symbol]
end
