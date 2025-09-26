module Effective
  class CommitteesController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)

    include Effective::CrudController
    log_page_views(if: -> { EffectiveCommittees.log_page_views? })

    resource_scope -> { Effective::Committee.all.deep }

    def index
      @committees = resource_scope.for_index
      @page_title = EffectiveResources.et('effective_committees.name')

      EffectiveResources.authorize!(self, :index, Effective::Committee)

      render 'index'
    end

    private

    def permitted_params
      model = (params.key?(:effective_committee) ? :effective_committee : :committee)
      params.require(model).permit!
    end

  end
end
