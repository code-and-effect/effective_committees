module Admin
  class CommitteeFilesController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)
    before_action { EffectiveResources.authorize!(self, :admin, :effective_committees) }

    include Effective::CrudController

    def bulk_move
      @committee_files = Effective::CommitteeFile.where(id: params[:ids])
      @committee_folder = Effective::CommitteeFolder.find_by_id(params[:committee_folder_id])

      @committee_files.each do |committee_file|
        committee_file.update!(committee_folder: @committee_folder, position: nil)
      end

      render json: { status: 200, message: "Successfully moved #{@committee_files.length} files to #{@committee_folder.title}" }
    rescue => e
      render json: { status: 500, message: "Unable to move files: #{e.message}" }
    end

    private

    def permitted_params
      model = (params.key?(:effective_committee_file) ? :effective_committee_file : :committee_file)
      params.require(model).permit!
    end

  end
end
