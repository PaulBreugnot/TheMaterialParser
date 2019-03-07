require 'java'
require_relative '../java/tabula-1.0.2-jar-with-dependencies.jar'

class DatasheetProcessController < ApplicationController

  def show
    @selection = DatasheetSelection.find(params[:selection_id])
    render 'show'
  end

  def processSelections
    puts params[:selections]



    params[:datasheet_process][:selections].each do |selection|
      # Tabula process

      ## Load the PDF datasheet from public storage
      datasheet = Datasheet.find(selection[:datasheetId])
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
      bea = Java::TechnologyTabulaExtractors::BasicExtractionAlgorithm.new();
      table = bea.extract(area).get(0);
      sb = Java::JavaLang::StringBuilder.new();
      (Java::TechnologyTabulaWriters::CSVWriter.new()).write(sb, table);
      csv = sb.toString();
      puts csv
      
    end

    respond_to do |format|
      format.json {render json: {} }
    end
  end

end
