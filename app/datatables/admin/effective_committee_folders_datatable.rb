module Admin
  class EffectiveCommitteeFoldersDatatable < Effective::Datatable
    datatable do
      reorder :position

      col :updated_at, visible: false
      col :created_at, visible: false

      col :id, visible: false

      col :committee

      col :title do |folder|
        link_to(folder.title, effective_committees.edit_admin_committee_folder_path(folder))
      end

      col :slug, visible: false
      col :body, visible: false

      col :committee_files, label: 'Files', visible: false
      col :committee_files_count, label: 'Files Count', visible: false

      actions_col
    end

    collection do
      folders = Effective::CommitteeFolder.deep.sorted

      if attributes[:committee_folder_id].present?
        folders = folders.where(committee_folder_id: attributes[:committee_folder_id])
      elsif attributes[:committee_id].present?
        folders = folders.where(
          committee_id: attributes[:committee_id],
          committee_type: attributes[:committee_type],
          committee_folder_id: nil
        )
      end

      folders
    end

  end
end
