module Uploads
  class FroalaController < ApplicationController
    before_filter :authenticate_user!
    def create
      upload = FroalaImageUpload.create! image:params[:file]
      respond_json({link:upload.image.url})
    end
    def destroy
      head :ok
    end   
    private 
    def respond_json hash
      render json:hash
    end    
  end 
end   