EffectiveCommittees.setup do |config|
  config.committees_table_name = :committees
  config.committee_members_table_name = :committee_members
  config.committee_folders_table_name = :committee_folders
  config.committee_files_table_name = :committee_files

  # Layout Settings
  # Configure the Layout per controller, or all at once
  # config.layout = { application: 'application', admin: 'admin' }

  # Committee Members can belong to a committee with a role
  config.use_effective_roles = false
end
