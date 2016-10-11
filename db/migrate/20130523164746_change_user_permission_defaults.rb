class ChangeUserPermissionDefaults < ActiveRecord::Migration
  def change
    change_column_default :users, :can_view_leads, true
    change_column_default :users, :can_manage_leads, true
    change_column_default :users, :can_view_appointments, true
    change_column_default :users, :can_manage_appointments, true
    change_column_default :users, :can_view_all_jobs, true
    change_column_default :users, :can_view_own_jobs, true
    change_column_default :users, :can_manage_jobs, true
    change_column_default :users, :can_view_all_proposals, true
    change_column_default :users, :can_view_assigned_proposals, true
    change_column_default :users, :can_manage_proposals, true
    change_column_default :users, :can_be_assigned_appointments, true
    change_column_default :users, :can_be_assigned_jobs, true
  end
end
