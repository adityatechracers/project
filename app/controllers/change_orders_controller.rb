class ChangeOrdersController < ApplicationController
  load_and_authorize_resource :proposal
  load_and_authorize_resource through: :proposal

  def new
  end


  def create
    @change_order.user_id = current_user.id

    respond_to do |format|
      if @change_order.save
        format.html { redirect_to proposal_path(@proposal.guid), notice: 'Change order was successfully created.' }
        format.json { render json: @change_order, status: :created, location: @change_order }
      else
        format.html { render action: 'new' }
        format.json { render json: @change_order.errors, status: :unprocessable_entity }
      end
    end
  end
end
