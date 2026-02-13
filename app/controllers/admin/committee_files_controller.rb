module Admin
  class CommitteeFilesController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)
    before_action { EffectiveResources.authorize!(self, :admin, :effective_committees) }

    include Effective::CrudController

    def bulk_move
      committee_folder = Effective::CommitteeFolder.find_by_id(params[:committee_folder_id])
      committee_files = Effective::CommitteeFile.sorted.where(id: params[:ids])
      original_folder = Effective::CommitteeFolder.find_by_id(committee_files.first.committee_folder_id)

      # Update the position of the files in the new folder
      position = (committee_folder.committee_files.map { |file| file.position }.compact.max || -1) + 1

      committee_files.each_with_index do |committee_file, index|
        committee_file.update!(committee_folder: committee_folder, position: position + index)
      end

      # Update the position of the files in the original folder
      original_folder.committee_files.each_with_index do |committee_file, index|
        committee_file.update!(position: index)
      end

      render json: { status: 200, message: "Successfully moved #{committee_files.length} files to #{committee_folder.title}" }
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
