class DatasheetsController < ApplicationController
  def index
    @newDatasheet = Datasheet.new
    @datasheetCategories = DatasheetCategory.all

    if params[:datasheet_category_id]
      @datasheetCategory = DatasheetCategory.find(params[:datasheet_category_id])
      @datasheets = @datasheetCategory.datasheets
    else
      @datasheets = Datasheet.all
    end

    respond_to do |format|
      format.html { render "index" }
      format.json { render json: @datasheets }
    end
  end

  def create
    @datasheetCategory = DatasheetCategory.find(params[:datasheet][:datasheet_category_id])
    added_datasheets = []
    params[:datasheet][:pdfDatasheet].each do |pdfFile|
      added_datasheets.push(@datasheetCategory.datasheets.create({name: pdfFile.original_filename, pdfDatasheet: pdfFile}))
    end

    respond_to do |format|
      format.html {
        if @datasheetCategory.datasheets
          if params[:datasheet][:pdfDatasheet].length > 1
            label = "#{params[:datasheet][:pdfDatasheet].length} datasheets"
          else
            label = "Datasheet #{@datasheet.name}"
          end
          redirect_to datasheets_url, notice: "#{label} has been uploaded to #{@datasheetCategory.name}."
        else
          redirect_to datasheets_url, alert: "An error occured."
        end
        }
      format.json { render json: added_datasheets }
    end
  end

  def destroy
  end

  private
    def datasheet_params
      params.require(:datasheet).permit(:name, :pdfDatasheet)
    end
end
