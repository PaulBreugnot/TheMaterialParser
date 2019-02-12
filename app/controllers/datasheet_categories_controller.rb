class DatasheetCategoriesController < ApplicationController
  def index
    @datasheet_categories = DatasheetCategory.all
    @selected_datasheet_category = @datasheet_categories[0]
    @new_datasheet_category = DatasheetCategory.new

    @new_datasheet = Datasheet.new
  end


  def datasheets
    respond_to do |format|
      format.json { render json: datasheets }
    end
  end

  def create
    @datasheetCategory = DatasheetCategory.new(datasheet_categories_params)

    if @datasheetCategory.save
       redirect_to datasheet_categories_path, notice: "Datasheet Category #{@datasheetCategory.name} has been created."
    else
       render "index"
    end
  end

  private
    def datasheet_categories_params
      params.require(:datasheet_category).permit(:name)
    end
end
