module Effective
  class CommitteesController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)

    include Effective::CrudController

    resource_scope -> { Effective::Committee.all.deep }

    private

    def permitted_params
      model = (params.key?(:effective_committee) ? :effective_committee : :committee)
      params.require(model).permit!
    end

  end
end
