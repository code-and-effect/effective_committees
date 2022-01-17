module EffectiveCommittees
  class Engine < ::Rails::Engine
    engine_name 'effective_committees'

    # Set up our default configuration options.
    initializer 'effective_committees.defaults', before: :load_config_initializers do |app|
      eval File.read("#{config.root}/config/effective_committees.rb")
    end

    # Include acts_as_addressable concern and allow any ActiveRecord object to call it
    initializer 'effective_committees.active_record' do |app|
      ActiveSupport.on_load :active_record do
        ActiveRecord::Base.extend(EffectiveCommitteesUser::Base)
      end
    end

  end
end
