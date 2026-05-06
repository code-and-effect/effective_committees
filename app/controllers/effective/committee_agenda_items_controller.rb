module Effective
  class CommitteeAgendaItemsController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)

    include Effective::CrudController
    log_page_views(if: -> { EffectiveCommittees.log_page_views? })

    resource_scope -> { Effective::CommitteeAgendaItem.deep }

  end
end
