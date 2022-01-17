# Dashboard Committees
class EffectiveCommitteesDatatable < Effective::Datatable
  datatable do
    order :title

    col :id, visible: false

    col :title
    col :committee_members

    actions_col
  end

  collection do
    Effective::Committee.deep.where(id: current_user.committees)
  end

end
