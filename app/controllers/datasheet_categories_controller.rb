class DatasheetCategoriesController < ApplicationController
  def index
    @datasheet_categories = DatasheetCategory.all

    respond_to do |format|
      format.html { render 'index' }
      format.json { render json: @datasheet_categories }
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

  def update
    @datasheetCategory = DatasheetCategory.find(params[:id])

    if @datasheetCategory.update(datasheet_categories_params)
      redirect_to datasheet_categories_path, notice: "Datasheet Category #{@datasheetCategory.name} updated."
    else
      redirect_to datasheet_categories_path, alert: "A server error occured."
    end
  end

  def remove_logo
    @datasheetCategory = DatasheetCategory.find(params[:id])
    @datasheetCategory.remove_logo!

    if @datasheetCategory.save
      redirect_to datasheet_categories_path, notice: "#{@datasheetCategory.name} logo deleted."
    else
      redirect_to datasheet_categories_path, alert: "A server error occured."
    end
  end

  def destroy
    @datasheetCategory = DatasheetCategory.find(params[:id])
    @datasheetCategory.destroy

    respond_to do |format|
      format.json {
        render json: DatasheetCategory.all
      }
    end

  end

  private
    def datasheet_categories_params
      params.require(:datasheet_category).permit(:name, :logo)
    end
end
