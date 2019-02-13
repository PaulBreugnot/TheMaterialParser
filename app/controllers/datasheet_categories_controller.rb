class DatasheetCategoriesController < ApplicationController
  def index
    @datasheet_categories = DatasheetCategory.all
    @new_datasheet_category = DatasheetCategory.new
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
