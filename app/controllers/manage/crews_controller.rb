module Manage
  class CrewsController < BaseController
    load_and_authorize_resource

    def index
      @crews = @crews.not_deleted
    end

    def show
    end

    def new
      @crew.set_color
    end

    def create
      @crew = Crew.new params[:crew]
      if @crew.save
        redirect_to manage_crews_path, :notice => "The crew has been created"
      else
        render "new"
      end
    end

    def edit
      @crew = Crew.find(params[:id])
    end

    def update
      respond_to do |format|
        if @crew.update_attributes! params[:crew]
          format.html {redirect_to manage_crews_path, :notice => "Crew successfully updated!"}
          format.json {render json: @crew}
        else
          format.html {render :edit}
          format.json {render json: @crew, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      redirect_to manage_crews_path, :notice => "Your crew has been deleted." if @crew.destroy
    end

  end
end
