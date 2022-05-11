class ProfilesController < ApplicationController
  before_action :authenticate_user!

  ALLOWED_USER_PARAMS = %i[name email username profile_image].freeze
  ALLOWED_USERS_SETTING_PARAMS = %i[display_email_on_profile brand_color1 brand_color2].freeze

  def update
    if any_form_exceptions
      flash[:error] = I18n.t("profiles_controller.too_low_contrast")
      return
    end

    update_result = Users::Update.call(current_user, update_params)
    if update_result.success?
      flash[:settings_notice] = I18n.t("profiles_controller.updated")
      redirect_to user_settings_path
    else
      @user = current_user
      @tab = "profile"
      flash[:error] = I18n.t("errors.messages.general", errors: update_result.errors_as_sentence)
      render template: "users/edit", locals: {
        user: update_params[:user],
        profile: update_params[:profile],
        users_setting: update_params[:users_setting]
      }
    end
  end

  def any_form_exceptions
    low_color_contrast(
      update_params[:users_setting][:brand_color1],
      update_params[:users_setting][:brand_color2],
    )
  end

  private

  def update_params
    params.permit(profile: Profile.attributes + Profile.static_fields,
                  user: ALLOWED_USER_PARAMS,
                  users_setting: ALLOWED_USERS_SETTING_PARAMS)
  end

  def low_color_contrast(bgkd_color, txt_color)
    Color::Accessibility.new(bgkd_color).low_contrast?(txt_color)
  end
end
