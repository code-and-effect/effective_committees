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
    parents = resource.parents + [resource]
    render(partial: 'admin/committees/parents', locals: { parents: parents }, formats: [:html])
  end

end
