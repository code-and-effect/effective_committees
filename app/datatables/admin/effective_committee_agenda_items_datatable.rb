module Admin
  class EffectiveCommitteeAgendaItemsDatatable < Effective::Datatable
    datatable do
      reorder :position

      col :updated_at, visible: false
      col :created_at, visible: false

      col :id, visible: false

      col :code, label: 'Code'
      col :title
      col :presenter
      col :timed_at, label: 'Timed'

      actions_col
    end

    collection do
      scope = Effective::CommitteeAgendaItem.deep.sorted

      if attributes[:committee_folder_id].present?
        scope = scope.where(committee_folder_id: attributes[:committee_folder_id])
      end

      scope
    end
  end
end
