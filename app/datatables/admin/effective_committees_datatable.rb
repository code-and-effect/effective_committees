module Admin
  class EffectiveCommitteesDatatable < Effective::Datatable
    datatable do

      col :updated_at, visible: false
      col :created_at, visible: false

      col :id, visible: false

      col :title, label: 'Committee'
      col :slug, visible: false
      col :body, visible: false

      col :committee_members, label: 'Members'
      col :committee_members_count, label: 'Members Count', visible: false

      col :committee_folders, label: 'Folders', visible: false
      col :committee_folders_count, label: 'Folders Count', visible: false

      col :committee_files, label: 'Files', visible: false
      col :committee_files_count, label: 'Files Count', visible: false

      actions_col do |committee|
        dropdown_link_to('View Committee', effective_committees.committee_path(committee), target: '_blank')
      end

    end

    collection do
      Effective::Committee.deep.all
    end

  end
end
