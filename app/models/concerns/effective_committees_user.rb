# EffectiveCommitteesUser
#
# Mark your user model with effective_committees_user to get all the includes

module EffectiveCommitteesUser
  extend ActiveSupport::Concern

  module Base
    def effective_committees_user
      include ::EffectiveCommitteesUser
    end
  end

  module ClassMethods
    def effective_committees_user?; true; end
  end

  included do
    has_many :committee_members, -> { Effective::CommitteeMember.sorted },
      class_name: 'Effective::CommitteeMember', inverse_of: :user, dependent: :delete_all

    accepts_nested_attributes_for :committee_members, allow_destroy: true
  end

  # Instance Methods

  def committee_member(committee:)
    committee_members.find { |rep| rep.committee_id == committee.id }
  end

  # Find or build
  def build_committee_member(committee:)
    committee_member(committee: committee) || committee_members.build(committee: committee)
  end

  def committees
    committee_members.select { |cm| cm.active? && !cm.marked_for_destruction? }.map { |cm| cm.committee }
  end

end
