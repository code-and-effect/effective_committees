# Dashboard Committees
class EffectiveCommitteesDatatable < Effective::Datatable
  datatable do
    order :title

    col :id, visible: false

    col :title, label: 'Committee'

    col :committee_members, search: :string, label: 'Members', visible: false

    col :committee_members_count, label: 'Members' do |committee|
      pluralize(committee.committee_members_count, 'members')
    end

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
    # This only displays active committees
    Effective::Committee.deep.where(id: current_user.committees)
  end

end
