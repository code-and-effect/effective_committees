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

      actions_col
    end

    collection do
      Effective::Committee.deep.all
    end

  end
end
