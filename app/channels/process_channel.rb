class ProcessChannel < ApplicationCable::Channel
  def subscribed
    puts "Client subscribed : process_#{params[:datasheet_selection_id]}"
    stream_from "process_#{params[:datasheet_selection_id]}"
  end
end
