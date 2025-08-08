module Admin
  class EffectiveCommitteeMembersDatatable < Effective::Datatable
    datatable do
      col :id, visible: false
      col :user_id, visible: false

      col :committee
      col :user

      if defined?(EffectiveMemberships)
        col(:member_number, label: 'Member #', sort: false) do |committee_member|
          committee_member.user.try(:membership).try(:number)
        end.search do |collection, term|
          memberships = Effective::Membership.where(owner_type: current_user.class.name).where('number ILIKE ?', "%#{term}%")
          collection.where(user_id: memberships.select('owner_id'))
        end
      end

      unless attributes[:user_id]
        col :email do |committee_member|
          mail_to(committee_member.user.email)
        end
      end

      col :category
      col :start_on
      col :end_on

      col :expired do |committee_member|
        badge('expired') if committee_member.expired?
      end

      if EffectiveCommittees.use_effective_roles
        col :roles, search: roles_collection
      end

      actions_col
    end

    collection do
      scope = Effective::CommitteeMember.deep.all

      if current_user.class.try(:effective_memberships_user?)
        scope = scope.includes(user: :membership)
      end

      scope
    end

    def roles_collection
      EffectiveRoles.roles_collection(Effective::CommitteeMember.new).map(&:second)
    end

  end
end
