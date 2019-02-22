class DatasheetProcessController < ApplicationController

  def show
    @selection = DatasheetSelection.find(params[:selection_id])
    render 'show'
  end

  def processSelections
    puts params[:selections]

    respond_to do |format|
      format.json {render json: {} }
    end
  end

end
