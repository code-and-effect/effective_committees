module EffectiveCommitteesHelper

  def committees_name_label
    et('effective_committees.name')
  end

  def committee_label
    et(Effective::Committee)
  end

  def committees_label
    ets(Effective::Committee)
  end

  def committee_member_label
    et(Effective::CommitteeMember)
  end

  def committee_members_label
    ets(Effective::CommitteeMember)
  end

  def committee_folder_label
    et(Effective::CommitteeFolder)
  end

  def committee_folders_label
    ets(Effective::CommitteeFolder)
  end

  def committee_file_label
    et(Effective::CommitteeFile)
  end

  def committee_files_label
    ets(Effective::CommitteeFile)
  end

  def admin_committees_parents(resource)
    parents = []
    parents << resource.committee if resource.respond_to?(:committee) && resource.committee.present?
    parents += resource.parents
    parents << resource

    render(partial: 'admin/committees/parents', locals: { parents: parents }, formats: [:html])
  end

  def committee_file_link(committee_file, label: nil)
    label = label.presence || committee_file.to_s
    return label unless committee_file.file.attached?
    link_to(label, url_for(committee_file.file), target: '_blank')
  end

end
