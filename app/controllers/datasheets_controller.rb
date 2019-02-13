class DatasheetsController < ApplicationController
  def index
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
    @datasheet_category = DatasheetCategory.find(params[:datasheet][:datasheet_category_id])
    @datasheet = @datasheet_category.datasheets.create(datasheet_params)

    respond_to do |format|
      format.html {
        if @datasheet
          redirect_to home_index_path, notice: "Datasheet #{@datasheet.name} has been uploaded to #{@datasheet_category.name}."
        else
          redirect_to home_index_path, alert: "An error occured."
        end
        }
      format.json { render json: @datasheet }
    end
  end

  def destroy
  end

  private
    def datasheet_params
      params.require(:datasheet).permit(:name, :pdfDatasheet)
    end
end
