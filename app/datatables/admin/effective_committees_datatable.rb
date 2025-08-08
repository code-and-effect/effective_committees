module Admin
  class EffectiveCommitteesDatatable < Effective::Datatable
    datatable do
      col :updated_at, visible: false
      col :created_at, visible: false

      col :id, visible: false

      col :title, label: committee_label
      col :slug, visible: false
      col :body, visible: false

      col :display_on_index, label: "Display on #{committees_name_label} page"
      col :display_on_dashboard

      col(:committee_members, label: committee_members_label) do |committee|
        committee.committee_members.select(&:active?).sort_by(&:to_s).map do |member|
          content_tag(:div, class: 'col-resource_item') do
            label = link_to(member.to_s, "/admin/users/#{member.user_id}/edit")
            badge = badge(member.category) if member.category.present?

            [label, badge].compact.join(' ').html_safe
          end
        end.join.html_safe
      end

      col :committee_members_count, label: "#{committee_members_label} Count", visible: false

      col :committee_folders, label: 'Folders', visible: false
      col :committee_folders_count, label: 'Folders Count', visible: false

      col :committee_files, label: 'Files', visible: false
      col :committee_files_count, label: 'Files Count', visible: false

      actions_col do |committee|
        dropdown_link_to("View #{committee_label}", effective_committees.committee_path(committee), target: '_blank')
      end

    end

    collection do
      Effective::Committee.deep.all
    end

  end
end
