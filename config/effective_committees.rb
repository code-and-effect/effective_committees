EffectiveCommittees.setup do |config|
  config.committees_table_name = :committees
  config.committee_members_table_name = :committee_members

  # Layout Settings
  # Configure the Layout per controller, or all at once
  # config.layout = { application: 'application', admin: 'admin' }

  # Committee Members can belong to a committee with a role
  config.use_effective_roles = false
end
