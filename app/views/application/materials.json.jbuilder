
json.materials @materials do |material|
  json.name material.name
  json.composition material.composition.components do |component|
    json.name component.name
    json.value component.value
    json.minValue component.minValue 
    json.maxValue component.maxValue
    json.balance component.balance
    json.residual component.residual
  end
end
