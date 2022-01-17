module Admin
  class EffectiveCommitteeFoldersDatatable < Effective::Datatable
    datatable do
      reorder :position

      col :updated_at, visible: false
      col :created_at, visible: false

      col :id, visible: false

      col :committee, search: :string

      col :title
      col :slug, visible: false
      col :body

      col :committee_files_count

      actions_col
    end

    collection do
      Effective::CommitteeFolder.deep.all
    end

  end
end
