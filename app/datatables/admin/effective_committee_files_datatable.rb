module Admin
  class EffectiveCommitteeFilesDatatable < Effective::Datatable
    datatable do
      col :updated_at, visible: false
      col :created_at, visible: false

      col :id, visible: false

      col :committee
      col :committee_folder, label: 'Folder'

      col :file
      col :title
      col :notes

      actions_col
    end

    collection do
      Effective::CommitteeFile.deep.all
    end

  end
end
