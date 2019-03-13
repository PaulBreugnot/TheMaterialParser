require 'securerandom'

require 'materials/material'
require 'materials/elements'
require 'materials/composition'

class MaterialsController < ApplicationController

  @@material_selections = { }

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

  def available_components
    @periodicElements = AvailablePeriodicElements.availableElementsBySymbols

    respond_to do |format|
      format.json { render :periodicElements }
    end
  end

  def search
    puts params
    @materials = Material.joins(:datasheet).where("materials.name LIKE ? AND datasheets.datasheet_category_id IN (?)", params[:name], params[:categories])
    respond_to do |format|
      format.json { render :materials }
    end
  end

  def create_selection
    uuid = SecureRandom.uuid
    @@material_selections[uuid] = []
    params[:materials].each do |material_id|
      @@material_selections[uuid].push(material_id)
    end

    respond_to do |format|
      format.json { render json: { uuid: uuid } }
    end
  end

  def delete_selection
    @@material_selections[params[:selection_uuid]].each do |material_id|
      Material.find(material_id).destroy
    end
    @@material_selections.delete(params[:selection_uuid])
  end
end
