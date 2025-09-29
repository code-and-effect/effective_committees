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

    scope :with_committee, -> (committees) {
      committees = Effective::Resource.new(Effective::Committee).search_any(committees) if committees.kind_of?(String)
      raise('expected an Effective::Committee') unless committees.present? && Array(committees).all? { |c| c.kind_of?(Effective::Committee) }

      committee_members = Effective::CommitteeMember.where(committee: committees).where(user_type: name)
      where(id: committee_members.select(:user_id))
    }
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

  # When activity is for sequential uploaded files, group them together like: "12 files were added to Board of Directors - April 2025 Meeting"
  def committees_recent_activity(limit: 100)
    logs = EffectiveLogging.Log.logged_changes.deep
      .where(changes_to_type: 'Effective::Committee', changes_to_id: committees.map(&:id))
      .order(created_at: :desc)

    # Recent activity should be for folders being created and files being uploaded/replaced
    logs = logs.select do |log|
      folder_created = (log.associated_type == 'Effective::CommitteeFolder' && log.message == 'Created')
      file_changed = (log.associated_type == 'Effective::CommitteeFile' && (log.message == 'Created' || log.details.dig(:changes, 'File').present?))
      folder_created || file_changed
    end

    # Returns an Array of Arrays where some are 1 length groups
    # Others are multiple length groups of file changes to one folder
    logs = logs.slice_when do |a, b|
      (a.changes_to_id != b.changes_to_id) || 
      (a.associated_type != b.associated_type) || 
      (b.associated_type == "Effective::CommitteeFolder") ||
      (a.associated.try(:committee_folder_id) != b.associated.try(:committee_folder_id))
    end

    logs.take(limit)
  end
end
