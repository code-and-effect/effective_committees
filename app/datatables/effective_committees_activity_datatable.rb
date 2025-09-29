# For the /committees/activity More Activity page
# Displays all the logged changes for this user's committees
class EffectiveCommitteesActivityDatatable < Effective::Datatable
  datatable do
    order :id, :desc

    col :updated_at, label: 'Date'
    col :id, visible: false

    col :user, label: 'Changed by', search: :string, sort: false
    col :changes_to, label: committee_label, search: current_user.committees
    col :associated, visible: false

    col :message, sort: false do |log|
      message = (log.message || '').gsub("\n", '<br>')
      associated_type = log.associated_type.gsub('Effective::', '').gsub('ActiveStorage::', '')

      if log.associated_id == attributes[:changes_to_id] && log.associated_type == attributes[:changes_to_type]
        message
      else
        "#{associated_type} #{log.associated_to_s} - #{message}"
      end

    end.search do |collection, term, column, sql_column|
      ilike = effective_resource.ilike
      collection.where("associated_type #{ilike} ? OR associated_to_s #{ilike} ? OR message #{ilike} ?", "%#{term}%", "%#{term}%", "%#{term}%")
    end

    col :details, visible: false, sort: false do |log|
      tableize_hash(log.details)
    end

    actions_col
  end

  collection do
    EffectiveLogging.Log.logged_changes.deep
      .where(changes_to_type: 'Effective::Committee', changes_to_id: current_user.committees.map(&:id))
      .where.not(associated_type: 'ActiveStorage::Attachment')
  end

end
