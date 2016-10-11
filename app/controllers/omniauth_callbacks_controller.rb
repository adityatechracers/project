class OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def google_oauth2
    @user = User.find_for_google_oauth2(request.env["omniauth.auth"], current_user)
    begin
      @google_calendar = GoogleCalendarWrapper.new(@user)
      @google_calendar.import_calendars
      calendars_ids = @user.google_calendars.pluck(:calendar_id)
      calendars_ids.each do |c|
        @google_calendar.import_events(c)
      end
    rescue => e
      logger.error {"#{e.message} #{e.backtrace.join("\n")}"}
      current_user.update_attributes(connected_to_google: false)
      flash[:error] = "We were not able to fetch data from #{current_user.name}'s Google account."
    end

    if @user.persisted? and @user.connected_to_google?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.google_data"] = request.env["omniauth.auth"]
      redirect_to appointments_path
    end

  end
end
