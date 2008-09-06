class TicketsController < ApplicationController
  def index
    @tickets = Ticket.find(:all)
    
    respond_to do |format|
      format.html
    end
  end
  
  def show
    @ticket = Ticket.find_by_number(params[:id])
    
    respond_to do |format|
      format.html
    end
  end
end
