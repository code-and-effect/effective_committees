require 'effective_resources'
require 'effective_datatables'
require 'effective_committees/engine'
require 'effective_committees/version'

module EffectiveCommittees

  def self.config_keys
    [
      :committees_table_name, :committee_members_table_name, :layout,
      :use_effective_roles
    ]
  end

  include EffectiveGem

end
