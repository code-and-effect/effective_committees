# Dashboard Committees
class EffectiveCommitteesDatatable < Effective::Datatable
  datatable do
    order :title

    col :id, visible: false

    col :title, label: 'Committee'

    col :committee_members, search: :string, label: 'Members'

    col :committee_folders, search: :string, label: 'Folders'

    col :committee_folders_count, label: 'Folders', visible: false do |committee|
      pluralize(committee.committee_folders_count, 'folders')
    end

    col :committee_files, search: :string, label: 'Files', visible: false

    col :committee_files_count, label: 'Files' do |committee|
      pluralize(committee.committee_files_count, 'files')
    end

    actions_col
  end

  collection do
    Effective::Committee.deep.where(id: current_user.committees)
  end

end
