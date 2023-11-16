module Admin
  class EffectiveCommitteeMembersDatatable < Effective::Datatable
    datatable do
      col :id, visible: false
      col :user_id, visible: false

      col :committee, search: :string
      col :user, search: :string

      unless attributes[:user_id]
        col :email do |committee_member|
          mail_to(committee_member.user.email)
        end
      end

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
      Effective::CommitteeMember.deep.all
    end

    def roles_collection
      EffectiveRoles.roles_collection(Effective::CommitteeMember.new).map(&:second)
    end

  end
end
