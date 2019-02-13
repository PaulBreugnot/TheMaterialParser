class HomeController < ApplicationController
  def index
    @datasheet_categories = DatasheetCategory.all
    @new_datasheet = Datasheet.new
  end
end
