class TicketsController < ApplicationController
  def show
    @ticket = Ticket.find_by_number(params[:id])
    
    respond_to do |format|
      format.html
    end
  end
end
