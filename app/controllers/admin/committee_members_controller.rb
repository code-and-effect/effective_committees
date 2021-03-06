module Admin
  class CommitteeMembersController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)
    before_action { EffectiveResources.authorize!(self, :admin, :effective_committees) }

    include Effective::CrudController

    private

    def permitted_params
      model = (params.key?(:effective_committee_member) ? :effective_committee_member : :committee_member)
      params.require(model).permit!
    end

  end
end
