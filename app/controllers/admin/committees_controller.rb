module Admin
  class CommitteesController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)
    before_action { EffectiveResources.authorize!(self, :admin, :effective_committees) }

    include Effective::CrudController

    resource_scope -> { Effective::Committee.deep.all }
    datatable -> { EffectiveResources.best('Admin::EffectiveCommitteesDatatable').new }

    private

    def permitted_params
      model = (params.key?(:effective_committee) ? :effective_committee : :committee)
      params.require(model).permit!
    end

  end
end
