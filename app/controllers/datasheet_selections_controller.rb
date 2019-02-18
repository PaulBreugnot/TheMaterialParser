class DatasheetSelectionsController < ApplicationController

  def create
    @datasheetSelection = DatasheetSelection.new(datasheet_selections_params)
    params[:datasheet_ids].each do |id|
      puts "Hey"
      @datasheetSelection.datasheets.push(Datasheet.find(id))
    end
    puts @datasheetSelection.datasheets
    @datasheetSelection.save

    respond_to do |format|
      format.json { render json: @datasheetSelection }
    end
  end

  def destroy
    @datasheetSelection = DatasheetSelection.find(params[:id])
    datasheetsCount = @datasheetSelection.datasheets.length

    if @datasheetSelection.selection_type == "delete"
      @datasheetSelection.datasheets.each do |datasheet|
        # Delete selection datasheets
        datasheet.destroy
      end
    end
    # Delete join table rows
    @datasheetSelection.datasheets.clear
    # Delete selection
    @datasheetSelection.destroy

    respond_to do |format|
      format.json {
        render json: @datasheetSelection.datasheet_category.datasheets
      }
    end
  end

  private
    def datasheet_selections_params
      params.require(:datasheet_selection).permit(:datasheet_category_id, :selection_type, :saved)
    end
end
