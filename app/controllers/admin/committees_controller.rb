module Admin
  class CommitteesController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)
    before_action { EffectiveResources.authorize!(self, :admin, :effective_committees) }

    include Effective::CrudController

    submit :save, 'Save'
    submit :save, 'Save and Add New', redirect: :new
    submit :save, 'Save and View', redirect: -> { effective_committees.committee_path(resource) }

    resource_scope -> { Effective::Committee.deep.all }

    private

    def permitted_params
      model = (params.key?(:effective_committee) ? :effective_committee : :committee)
      params.require(model).permit!
    end

  end
end
