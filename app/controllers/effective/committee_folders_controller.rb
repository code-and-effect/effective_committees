module Effective
  class CommitteeFoldersController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)

    include Effective::CrudController

    resource_scope -> { Effective::CommitteeFolder.deep }

  end
end
