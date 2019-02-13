class DatasheetSelectionsController < ApplicationController

  def create
    @datasheetSelection = DatasheetSelection.new(datasheet_selections_params)
    params[:datasheet_ids].each do |id|
      puts "Hey"
      @datasheetSelection.datasheets.push(Datasheet.find(id))
    end
    @datasheetSelection.save

    respond_to do |format|
      format.json { render json: @datasheetSelection }
    end
  end

  def destroy
  end

  private
    def datasheet_selections_params
      params.require(:datasheet_selection).permit(:selection_type, :saved)
    end
end
