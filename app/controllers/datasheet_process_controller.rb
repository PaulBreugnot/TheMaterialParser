class DatasheetProcessController < ApplicationController

  def show
    @selection = DatasheetSelection.find(params[:selection_id])
    render 'show'
  end

end
