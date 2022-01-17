module Admin
  class CommitteeFoldersController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)
    before_action { EffectiveResources.authorize!(self, :admin, :effective_committees) }

    include Effective::CrudController

    private

    def permitted_params
      model = (params.key?(:effective_committee_folder) ? :effective_committee_folder : :committee_folder)
      params.require(model).permit!
    end

  end
end
