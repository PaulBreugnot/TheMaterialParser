require 'materials/material'

class MaterialsController < ApplicationController
  def index
    @materials = Material.all

    respond_to do |format|
      format.html { render 'index' }
      format.json { render :materials }
    end
  end

  def download_csv
    @materials = Material.all
    csv_materials = CSV.generate do |csv|
      csv << ["material", "component", "value", "minValue", "maxValue", "balance", "residual"]
      @materials.each do |material|
        material.composition.components.each do |component|
          csv << [material.name, component.name, component.value, component.minValue, component.maxValue, component.balance, component.residual]
        end
      end
    end

    send_data csv_materials, filename: "materials.csv"
  end
end
