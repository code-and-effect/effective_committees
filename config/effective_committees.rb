EffectiveCommittees.setup do |config|
  # Layout Settings
  # Configure the Layout per controller, or all at once
  # config.layout = { application: 'application', admin: 'admin' }

  # Committee Members can belong to a committee with a role
  config.use_effective_roles = true

  # Uses EffectiveLogging to log page views for front end committees pages
  config.log_page_views = false
end
