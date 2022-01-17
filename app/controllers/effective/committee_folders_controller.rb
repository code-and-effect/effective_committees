module Effective
  class CommitteeFoldersController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)

    include Effective::CrudController
  end
end
