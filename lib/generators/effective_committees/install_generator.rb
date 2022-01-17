module EffectiveMemberships
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      desc 'Creates an EffectiveCommittees initializer in your application.'

      source_root File.expand_path('../../templates', __FILE__)

      def self.next_migration_number(dirname)
        if not ActiveRecord::Base.timestamped_migrations
          Time.new.utc.strftime("%Y%m%d%H%M%S")
        else
          '%.3d' % (current_migration_number(dirname) + 1)
        end
      end

      def copy_initializer
        template ('../' * 3) + 'config/effective_committees.rb', 'config/initializers/effective_committees.rb'
      end

      def create_migration_file
        @committees_table_name  = ':' + EffectiveCommittees.committees_table_name.to_s
        @committee_members_table_name  = ':' + EffectiveCommittees.committee_members_table_name.to_s

        migration_template ('../' * 3) + 'db/migrate/01_create_effective_committees.rb.erb', 'db/migrate/create_effective_committees.rb'
      end

    end
  end
end