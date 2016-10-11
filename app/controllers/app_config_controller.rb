class AppConfigController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json 
  def froala
    config_for :froala
  end 
  private 
  def config_for name  
    respond_with Rails.application.config.send(name)
  end   
end   