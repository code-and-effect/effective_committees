module Admin
  class EffectiveCommitteeMembersDatatable < Effective::Datatable
    datatable do
      col :id, visible: false
      col :user_id, visible: false

      col :committee
      col :user

      unless attributes[:user_id]
        col :email do |committee_member|
          mail_to(committee_member.user.email)
        end
      end

      if EffectiveCommittees.use_effective_roles
        col :roles, search: roles_collection
      end

      actions_col
    end

    collection do
      Effective::CommitteeMember.deep.all
    end

    def roles_collection
      EffectiveRoles.roles_collection(Effective::CommitteeMember.new).map(&:second)
    end

  end
end
