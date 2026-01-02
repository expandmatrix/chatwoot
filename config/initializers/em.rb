Rails.application.config.to_prepare do
  # Ensure EM envs are present for webhook client
  ENV['EM_API_BASE_URL'] ||= 'http://api:3001'
  ENV['MESSAGING_WEBHOOK_ENABLED'] ||= 'true'
end
