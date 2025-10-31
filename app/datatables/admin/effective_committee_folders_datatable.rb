module Admin
  class EffectiveCommitteeFoldersDatatable < Effective::Datatable
    datatable do
      reorder :position

      col :updated_at, visible: false
      col :created_at, visible: false

      col :id, visible: false

      col :committee

      col :parents, label: "Folders" do |committee_folder|
        admin_committees_parents(committee_folder)
      end

      col :slug, visible: false
      col :body, visible: false

      col :committee_files, label: 'Files', visible: false
      col :committee_files_count, label: 'Files Count', visible: false

      actions_col
    end

    collection do
      folders = Effective::CommitteeFolder.deep.sorted.all

      if attributes[:committee_folder_id].present?
        folders = folders.where(id: committee_folder.children)
      end

      folders
    end

    def committee_folder
      @committee_folder ||= Effective::CommitteeFolder.find_by_id(attributes[:committee_folder_id])
    end

  end
end
