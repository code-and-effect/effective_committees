module Admin
  class EffectiveCommitteeFoldersDatatable < Effective::Datatable
    datatable do
      reorder :position

      col :updated_at, visible: false
      col :created_at, visible: false

      col :id, visible: false

      col :committee

      col :title, label: 'Folder'
      col :slug, visible: false
      col :body, visible: false

      col :committee_files, label: 'Files', visible: false
      col :committee_files_count, label: 'Files Count', visible: false

      actions_col
    end

    collection do
      Effective::CommitteeFolder.deep.all
    end

  end
end
