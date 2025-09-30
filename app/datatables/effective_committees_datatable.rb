# Dashboard Committees
class EffectiveCommitteesDatatable < Effective::Datatable
  datatable do
    length 100
    order :title

    col :id, visible: false

    col :title, label: committee_label

    col(:committee_members, label: committee_members_label, visible: false) do |committee|
      committee.committee_members.select(&:active?).sort_by(&:to_s).map do |member|
        content_tag(:div, class: 'col-resource_item') do
          label = member.to_s
          badge = badge(member.category) if member.category.present?

          [label, badge].compact.join(' ').html_safe
        end
      end.join.html_safe
    end

    col :committee_members_count, as: :string, label: committee_members_label do |committee|
      pluralize(committee.committee_members.select(&:active?).length, committee_member_label.downcase)
    end

    col :committee_folders, label: 'Folders'

    col :committee_folders_count, as: :string, label: 'Folders', visible: false do |committee|
      pluralize(committee.committee_folders_count, 'folders')
    end

    col :committee_files, label: 'Files', visible: false

    col :committee_files_count, as: :string, label: 'Files' do |committee|
      pluralize(committee.committee_files_count, 'files')
    end

    actions_col
  end

  collection do
    # This only displays committees published to the dashboard that the committee_member has active? access to
    Effective::Committee.deep.for_dashboard.where(id: current_user.committees)
  end

end
