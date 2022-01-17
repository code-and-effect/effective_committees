module Effective
  class CommitteeMembersController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)

    include Effective::CrudController

    resource_scope -> {
      committees = Effective::Committee.deep.where(id: current_user.committees)
      Effective::CommitteeMember.deep.where(committee: committees)
    }

    private

    def permitted_params
      params.require(:effective_committee_member).permit!
    end

  end
end
