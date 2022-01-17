module Admin
  class CommitteeFilesController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)
    before_action { EffectiveResources.authorize!(self, :admin, :effective_committees) }

    include Effective::CrudController

    private

    def permitted_params
      model = (params.key?(:effective_committee_file) ? :effective_committee_file : :committee_file)
      params.require(model).permit!
    end

  end
end
