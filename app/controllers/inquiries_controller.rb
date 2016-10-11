class InquiriesController < ApplicationController
  # POST /inquiries
  # POST /inquiries.json
  def create
    @inquiry = Inquiry.new(params[:inquiry])

    respond_to do |format|
      if @inquiry.save
        InquiriesMailer.new_inquiry(@inquiry).deliver
        format.html do
          redirect_loc = current_user.present? ? dashboard_path : root_path
          redirect_to redirect_loc, notice: 'Thanks for your message!'
        end
        format.json { render json: @inquiry, status: :created, location: @inquiry }
      else
        format.html { redirect_to manage_subscription_path, alert: 'Your message could not be saved' }
        format.json { render json: @inquiry.errors, status: :unprocessable_entity }
      end
    end
  end
end
