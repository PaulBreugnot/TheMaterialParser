require 'java'
require_relative '../java/tabula-1.0.2-jar-with-dependencies.jar'

require 'materials/material'
require 'materials/composition'

class DatasheetProcessController < ApplicationController
  # Hash that map selections ids to result list, that have not been saved yet.
  @@waitingResults = {}

  def show
    @selection = DatasheetSelection.find(params[:selection_id])
    render 'show'
  end

  def processSelections
    puts params[:selections]

    datasheet_selection = DatasheetSelection.find(params[:datasheet_process][:datasheet_selection_id])
    @@waitingResults[params[:datasheet_process][:datasheet_selection_id]] = []

    datasheet_selection.datasheets.each do |datasheet|

      material = Material.new
      material.datasheet = datasheet
      material.name = File.basename(datasheet.pdfDatasheet.url)[/(.+)\.pdf/, 1]

      params[:datasheet_process][:selections].each do |selection|
        # Tabula process

        ## Load the PDF datasheet from public storage
        datasheet = Datasheet.find(datasheet.id)
        pdf_abs_path = "#{Rails.public_path}#{datasheet.pdfDatasheet.url}"
        document = Java::OrgApachePdfboxPdmodel::PDDocument.load(java.io.File.new(pdf_abs_path))
        puts document

        ## Extract page
        oe = Java::TechnologyTabula::ObjectExtractor.new(document)
        page = oe.extract(selection[:page])
        puts page
        realPageWidth = page.getWidth()
        ratio = realPageWidth / selection[:canvasWidth]

        ## Extract area
        scaledX = selection[:x] * ratio
        scaledY = selection[:y] * ratio
        scaledWidth = selection[:width] * ratio
        scaledHeight = selection[:height] * ratio

        area = page.getArea(scaledY, scaledX, scaledY + scaledHeight, scaledX + scaledWidth) #top, left, bottom, right
        puts area

        oe.close()

        ## Extract table
        bea = Java::TechnologyTabulaExtractors::BasicExtractionAlgorithm.new()
        table = bea.extract(area).get(0)
        sb = Java::JavaLang::StringBuilder.new()
        (Java::TechnologyTabulaWriters::CSVWriter.new()).write(sb, table)
        csv = sb.toString()

        extracted_composition = Composition.parseFromCsv(csv, orientation=selection[:orientation].to_sym, headers=selection[:headers])
        if extracted_composition
          if material.composition
            if extracted_composition.components.size > material.composition.components.size
              material.composition = extracted_composition
            end
          else
            material.composition = extracted_composition
          end
        end

        # material.composition = Composition.parseFromCsv(csv, orientation=selection[:orientation].to_sym, headers=selection[:headers])
      end
      if material.composition
        ActionCable.server.broadcast(
          "process_#{params[:datasheet_process][:datasheet_selection_id]}",
          datasheet_id: datasheet.id,
          status: 'ok',
        )
        @@waitingResults[params[:datasheet_process][:datasheet_selection_id]].push(material)
      else
        ActionCable.server.broadcast(
          "process_#{params[:datasheet_process][:datasheet_selection_id]}",
          datasheet_id: datasheet.id,
          status: 'warning',
        )
      end
    #  end
    end

    puts @@waitingResults[params[:datasheet_process][:datasheet_selection_id]].inspect

    @materials = @@waitingResults[params[:datasheet_process][:datasheet_selection_id]]
    respond_to do |format|
      format.json { render :results }
    end
  end

  def download_csv
    materials_data = @@waitingResults[params[:datasheet_selection_id]]
    puts params[:datasheet_selection_id]
    puts @@waitingResults
    csv_materials = CSV.generate do |csv|
      csv << ["material", "component", "value", "minValue", "maxValue", "balance", "residual"]
      materials_data.each do |material|
        material.composition.components.each do |component|
          csv << [material.name, component.name, component.value, component.minValue, component.maxValue, component.balance, component.residual]
        end
      end
    end

    send_data csv_materials, filename: "materials.csv"
  end

  def save_to_database

  end

end
