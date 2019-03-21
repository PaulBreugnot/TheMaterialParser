if @searchResultUuid
  json.selection_uuid @searchResultUuid
end

json.materials @materials do |material|
  if material.id
    json.id material.id
  end
  json.name material.name
  if material.datasheet
    json.original_pdf material.datasheet.pdfDatasheet.url
  end
  json.composition material.composition.components do |component|
    json.name component.name
    json.value component.value
    json.minValue component.minValue
    json.maxValue component.maxValue
    json.balance component.balance
    json.residual component.residual
  end
end

if @datasheetStatus
  json.datasheet_status @datasheetStatus.each do |datasheet_id, datasheetStatus|
    json.datasheet_id datasheet_id
    json.status datasheetStatus
  end
end
