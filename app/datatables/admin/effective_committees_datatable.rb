module Admin
  class EffectiveCommitteesDatatable < Effective::Datatable
    datatable do

      col :updated_at, visible: false
      col :created_at, visible: false

      col :id, visible: false

      col :title
      col :slug, visible: false

      col :committee_members_count
      col :committee_members

      actions_col do |committee|
        dropdown_link_to('View Committee', effective_committees.committee_path(committee), target: '_blank')
      end

    end

    collection do
      Effective::Committee.deep.all
    end

  end
end
