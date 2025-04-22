class EffectiveCommitteeMembersDatatable < Effective::Datatable
  datatable do
    col :id, visible: false

    col :committee
    col :user

    unless attributes[:user_id]
      col :email do |committee_member|
        mail_to(committee_member.user.email)
      end
    end

    col :start_on
    col :end_on

    if EffectiveCommittees.use_effective_roles
      col :roles, search: roles_collection
    end

    unless attributes[:actions] == false
      actions_col
    end

  end

  collection do
    scope = Effective::CommitteeMember.deep.all.where(committee: current_user.committees)

    if current_user.class.try(:effective_memberships_user?)
      scope = scope.includes(user: :membership)
    end

    if attributes[:committee_id]
      scope = scope.where(committee_id: attributes[:committee_id])
    end

    if attributes[:user_id]
      scope = scope.where(user_id: attributes[:user_id])
    end

    scope
  end

  def roles_collection
    EffectiveRoles.roles_collection(Effective::CommitteeMember.new).map(&:second)
  end

end
