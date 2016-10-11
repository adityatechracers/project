module Manage
  class OrganizationsController < BaseController
    layout 'dashboard'

    # GET /manage/organization/edit
    def edit
      @organization = current_tenant
      @signature_of_user = @organization.default_signature
      @user_name = "Default Signature of the Organization"
    end

    def get_signature
      @organization = current_tenant
      @signature_of_user = nil
      if params.has_key?(:user_id) && params[:user_id] != ""
        if !@organization.user_signatures.nil?
          found = false
          @organization.user_signatures.each do |v|
            if v[:signature_for_user_id] == params[:user_id]
             found = true
             @signature_of_user = v[:signature_value]
            end
            if found == false
              @signature_of_user = nil
            end
          end
        else
          @signature_of_user = nil
        end
        id_of_user = params[:user_id].to_i
        @user_name = User.find(id_of_user).name
      else
        @signature_of_user = @organization.default_signature
        @user_name = "Default Signature of the Organization"
      end
      render :partial => "signature_form"
    end

    def change_signature
      @organization = current_tenant
      if params[:user_id] =="" || params[:user_id] == nil
        if params[:signature_value] == ""
          @organization.default_signature = nil
          @signature_of_user = nil
        else
        @organization.default_signature = params[:signature_value]
        @signature_of_user = params[:signature_value]
        end
        @organization.save
        @user_name = "Default Signature of the Organization"
      else
        if !@organization.user_signatures.nil?
          found = false
          found_index = -1
          @organization.user_signatures.each_with_index do |v, index|
            if v[:signature_for_user_id] == params[:user_id]
              found = true
              found_index = index
              v[:signature_value] = params[:signature_value]
              @signature_of_user = params[:signature_value]
            end
          end
          if (params[:signature_value] == nil || params[:signature_value] == "") && found == true
            @organization.user_signatures.delete_at(found_index)
            @signature_of_user = nil
          end
          if found == false && params[:signature_value] != ""
            @organization.user_signatures.push({signature_for_user_id: params[:user_id], signature_value: params[:signature_value] })
            @signature_of_user = params[:signature_value]
          end
          @organization.save
          @user_name = User.find(params[:user_id]).name
        else
          @organization.user_signatures = []
          @organization.user_signatures.push({signature_for_user_id: params[:user_id], signature_value: params[:signature_value] })
          @organization.save
          @user_name = User.find(params[:user_id]).name
          @signature_of_user = params[:signature_value]
        end
      end
      render :partial => "signature_form"
    end


    # PUT /manage/organization
    # PUT /manage/organization.json
    def update
      @organization = current_tenant
      if @organization.user_signatures == "" ||  @organization.user_signatures.nil?
              @organization.user_signatures = []
      end
      respond_to do |format|
          if @organization.update_attributes(params[:organization].except(:user_signatures,:default_signature))
            format.html { redirect_to manage_edit_organization_path, notice: 'Organization was successfully updated.' }
            format.json { head :no_content }
          else
            format.html { render action: "edit" }
            format.json { render json: @organization.errors, status: :unprocessable_entity }
          end
      end
    end
  end
end
