module Effective
  class CommitteeFoldersController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)

    include Effective::CrudController
    log_page_views(if: -> { EffectiveCommittees.log_page_views? })

    resource_scope -> { Effective::CommitteeFolder.deep }

    def agenda
      @committee_folder = resource_scope.find(params[:id])
      EffectiveResources.authorize!(self, :agenda, @committee_folder)
    end

  end
end
