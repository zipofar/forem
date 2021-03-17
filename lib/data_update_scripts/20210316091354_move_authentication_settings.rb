module DataUpdateScripts
  class MoveAuthenticationSettings
    AUTHENTICATION_SETTINGS = %w[
      allow_email_password_login
      allow_email_password_registration
      allowed_registration_email_domains
      apple_client_iapple_key_iapple_peapple_team_id, type: :string
      authentication_providers
      display_email_d :boolean
      facebook_key
      facebook_secret
      github_key
      github_secret
      invite_only_mode
      require_captcha_for_email_password_registration
      twitter_key
      twitter_secret
    ].freeze

    def run
      ApplicationRecord.connection.execute(<<~SQL.squish, AUTHENTICATION_SETTINGS)
        INSERT into settings_authentications (var, value, created_at, updated_at)
        SELECT var, value, now(), now() from site_configs
        WHERE var in (?)
      SQL
    end
  end
end
