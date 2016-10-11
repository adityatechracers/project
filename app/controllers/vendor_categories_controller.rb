class VendorCategoriesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    @vendor_categories = @vendor_categories.not_deleted
  end

  def new
    @vendor_category = VendorCategory.new
  end

  def create
    @vendor_category = current_user.organization.vendor_categories.new(params[:vendor_category])

    respond_to do |format|
      if @vendor_category.save
        format.html { redirect_to vendor_categories_path, notice: 'Vendor  was successfully created.' }
        format.json { render json: @vendor_category, status: :created, location: @vendor_category }
      else
        format.html { render action: 'new' }
        format.json { render json: @vendor_category.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @vendor_category = VendorCategory.find(params[:id])
  end

  def update
    @vendor_category = VendorCategory.find(params[:id])

    respond_to do |format|
      if @vendor_category.update_attributes(params[:vendor_category])
        format.html { redirect_to vendor_categories_path, notice: 'Vendor  was successfully updated' }
        format.json { render json: @vendor_category, status: :created, location: @vendor_category }
      else
        format.html { render action: 'edit' }
        format.json { render json: @vendor_category.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @vendor_category = VendorCategory.find(params[:id])

    respond_to do |format|
      if @vendor_category.destroy
        format.html { redirect_to vendor_categories_path, notice: 'Vendor  was successfully deleted' }
        format.json { head :no_content }
      else
        format.html { redirect_to vendor_categories_path, error: 'Vendor  could not be deleted' }
        format.json { head :unprocessable_entity }
      end
    end
  end
end
