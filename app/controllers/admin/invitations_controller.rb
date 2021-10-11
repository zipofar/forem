module Admin
  class InvitationsController < Admin::ApplicationController
    layout "admin"

    def index
      @invitations = User.where(registered: false).page(params[:page]).per(50)
    end

    def new; end

    def create
      email = params.dig(:user, :email)
      name = params.dig(:user, :name)

      if User.exists?(email: email.downcase, registered: true)
        flash[:error] = "Invitation was not sent. There is already a registered user with the email: #{email}"
        redirect_to admin_invitations_path
        return
      end

      username = "#{name.downcase.tr(' ', '_').gsub(/[^0-9a-z ]/i, '')}_#{rand(1000)}"
      @invited_user = nil
      User.invite!(email: email,
                   name: name,
                   username: username,
                   remote_profile_image_url: ::Users::ProfileImageGenerator.call,
                   registered: false) { |user| @invited_user = user }

      url = accept_invitation_url(@invited_user, invitation_token: @invited_user.raw_invitation_token)
      flash[:success] =
        "The invite has been sent to the user's email. Shareable one-time link \n#{url}\n"
      redirect_to admin_invitations_path
    end

    def destroy
      @invitation = User.where(registered: false).find(params[:id])
      if @invitation.destroy
        flash[:success] = "The invitation has been deleted."
      else
        flash[:danger] = @invitation.errors_as_sentence
      end
      redirect_to admin_invitations_path
    end
  end
end
