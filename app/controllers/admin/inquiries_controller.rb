module Admin
  class InquiriesController < BaseController
    load_and_authorize_resource

    # GET /admin/inquiries
    # GET /admin/inquiries.json
    def index
      @inquiries = @inquiries.order('created_at DESC').page params[:page]

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @inquiries }
      end
    end

    # GET /admin/inquiries/1
    # GET /admin/inquiries/1.json
    def show
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @inquiry }
      end
    end

    # DELETE /admin/inquiries/1
    # DELETE /admin/inquiries/1.json
    def destroy
      @inquiry.destroy

      respond_to do |format|
        format.html { redirect_to admin_inquiries_url }
        format.json { head :no_content }
      end
    end
  end
end
