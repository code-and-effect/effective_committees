module Admin
  class CommitteeAgendaItemsController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)
    before_action { EffectiveResources.authorize!(self, :admin, :effective_committees) }

    include Effective::CrudController

    private

    def permitted_params
      model = (params.key?(:effective_committee_agenda_item) ? :effective_committee_agenda_item : :committee_agenda_item)
      params.require(model).permit!
    end

  end
end
