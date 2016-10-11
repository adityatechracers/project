class Ability
  include CanCan::Ability

  def initialize(user)
    if user

      if user.is_admin?
        can :manage, :all
        cannot :edit, User, :super => true # Super users can't be modified through the app
        cannot :manage, User unless user.admin_can_manage_accounts
        cannot :manage, Organization unless user.admin_can_manage_accounts
        cannot :view_failing_credit_cards, :admin unless user.admin_can_view_failing_credit_cards
        cannot :view_billing_history, :admin unless user.admin_can_view_billing_history
        cannot :manage_trials, :admin unless user.admin_can_manage_trials
        cannot :manage_cms, :admin unless user.admin_can_manage_cms
        cannot :become_user, :admin unless user.admin_can_become_user
        cannot :manage_admin, :admin unless user.super
        unless user.super
          can :read, ProposalTemplate, :organization_id => 0
          can :manage, ProposalTemplate, :organization_id => 0
        end
        return
      end

      if user.can_manage?
        can :read, LeadSource, :organization_id => 0

        can :manage, Appointment
        can :manage, ChangeOrder
        can :manage, Communication
        can :manage, Contact
        can :manage, Crew
        can :manage, EmailTemplate
        can :manage, Expense
        can :manage, ExpenseCategory
        can :manage, VendorCategory
        can :manage, Job
        can :manage, JobUser
        can :manage, JobScheduleEntry, :job => { :organization_id => user.organization_id }
        can :manage, JobFeedback, :job => { :organization_id => user.organization_id }
        can :create, JobScheduleEntry
        can :manage, LeadSource, :modifiable => true
        can :manage, LeadUpload
        can :manage, Organization, :id => user.organization.id
        can :manage, Payment
        can :manage, Proposal
        can :manage, ProposalTemplate
        can :manage, ProposalTemplateItem
        can :manage, ProposalTemplateSection
        can :manage, Timecard
        can :manage, User

        # BECOME USER PERMISSION (Last updated 1/28/15)
        #
        # Note that some of this is defined above and below.
        #
        # Admins with the become user permission can become any user in the system.
        # Admins without the permission set cannot become other users.
        #
        # Owners can become any user in the owner's organization and any user
        # in a managed organization.
        #
        # A manager can become any employee in the manager's organization or
        # any user in a managed organization (including owners).
        #
        # Other users cannot become other users.

        cannot :become, User
        can :become, User, organization: { parent_organization_id: user.organization_id }
        can :become, User, role: 'Employee', organization_id: user.organization_id

        if user.is_owner?
          can :become, User, role: 'Manager', organization_id: user.organization_id
          cannot :become, User, role: 'Owner', organization_id: user.organization_id
        else
          cannot :become, User, role: ['Owner', 'Manager'], organization_id: user.organization_id
          cannot :edit, User, role: ['Owner', 'Manager']
          can :edit, User, id: user.id
        end

        return
      end

      # JOBS
      if user.can_view_all_jobs
        can :read, Job
        can :read, JobScheduleEntry, :job => { :organization_id => user.organization_id }
        can :read, JobFeedback, :job => { :organization_id => user.organization_id }
      elsif user.can_view_own_jobs
        # Using hashes with CanCan here causes it to join incorrectly, see: github.com/ryanb/cancan/issues/213
        can :read, Job, ['jobs.crew_id in (select crew_id from crews_users where user_id = ?)', user.id] { true }
        can :read, Job, ['jobs.id in (select job_id from job_users where user_id = ?)', user.id] { true }

        # Permission to view an entry can come from the job...
        can :read, JobScheduleEntry, ['job_schedule_entries.job_id in (select job_id from job_users where user_id = ?)', user.id] { true }
        can :read, JobScheduleEntry, ['job_schedule_entries.job_id in (select id from jobs where crew_id in (select crew_id from crews_users where user_id = ?))', user.id] { true }

        # ...or the schedule entry.
        can :read, JobScheduleEntry, ['job_schedule_entries.crew_id in (select crew_id from crews_users where user_id = ?)', user.id] { true }
        can :read, JobScheduleEntry, ['job_schedule_entries.id in (select job_schedule_entry_id from job_schedule_entry_users where user_id = ?)', user.id] { true }
      end
      if user.can_manage_jobs
        if user.can_view_all_jobs
          can :manage, Job
          can :manage, JobScheduleEntry, :job => { :organization_id => user.organization_id }
        else
          can :manage, Job, ['jobs.crew_id in (select crew_id from crews_users where user_id = ?)', user.id] { true }
          can :manage, Job, ['jobs.id in (select job_id from job_users where user_id = ?)', user.id] { true }

          can :manage, JobScheduleEntry, ['job_schedule_entries.job_id in (select job_id from job_users where user_id = ?)', user.id] { true }
          can :manage, JobScheduleEntry, ['job_schedule_entries.job_id in (select id from jobs where crew_id in (select crew_id from crews_users where user_id = ?))', user.id] { true }
          can :manage, JobScheduleEntry, ['job_schedule_entries.crew_id in (select crew_id from crews_users where user_id = ?)', user.id] { true }
          can :manage, JobScheduleEntry, ['job_schedule_entries.id in (select job_schedule_entry_id from job_schedule_entry_users where user_id = ?)', user.id] { true }
        end
        can :manage, Expense
        can :manage, ExpenseCategory
        can :manage, VendorCategory
        can :manage, Payment
      end

      # USERS
      cannot :become, User

      # TIMECARDS
      can :create, Timecard if user.can_make_timecards
      can :read, Timecard, :user_id => user.id
      can :manage, Timecard, :user_id => user.id, :state => 'Entered'
      cannot :manage, Timecard.locked_timecards if user.organization.timecard_locks_enabled?
      cannot :approve, Timecard

      # LEADS
      if user.can_view_leads
        can :read, Job, :state => 'Lead'
        can :read, Contact, :jobs => {:state => 'Lead'}
        can :read, Communication, :job => {:state => 'Lead'}
      end
      if user.can_manage_leads
        can :manage, Job, :state => 'Lead'
        can :manage, Contact, :jobs => {:state => 'Lead'}
        can :manage, Communication, :job => {:state => 'Lead'}
      end

      # PROPOSALS
      if user.can_view_all_proposals
        can :read, Proposal
      elsif user.can_view_assigned_proposals
        can :read, Proposal, :sales_person_id => user.id
        can :read, Proposal, :contractor_id => user.id
      end
      if user.can_manage_proposals
        if user.can_view_all_proposals
          can :manage, Proposal
          can :manage, ChangeOrder
        else
          can :manage, Proposal, :sales_person_id => user.id
          can :manage, Proposal, :contractor_id => user.id
          can :manage, ChangeOrder, proposal: { :sales_person_id => user.id }
          can :manage, ChangeOrder, proposal: { :contractor_id => user.id }
        end
      end

      # APPOINTMENTS
      can :read, Appointment if user.can_view_appointments
      can :manage, Appointment if user.can_manage_appointments

      # QUOTES
      can :read, Quote

      # CONTACTS
      #
      # Because they're displayed on almost every page, all users need to be
      # able to view contacts in their organization.
      #
      # Contacts with jobs in the lead state can additionally be managed
      # by users able to manage leads.
      #
      # Users with the `can_view_all_contacts` have the ability to view the
      # contacts tab and see all contacts.
      #
      # Users with the `can_manage_all_contacts`, which depends on the previous
      # permission, can additionally manage all contacts (even those not connected
      # to leads) from the contacts tab.
      can :read, Contact

      can :manage, Contact if user.can_manage_all_contacts

      user.can_view_all_contacts ? can(:view_all, Contact) : cannot(:view_all, Contact)
    end
  end
end
