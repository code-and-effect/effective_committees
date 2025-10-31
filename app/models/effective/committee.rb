# frozen_string_literal: true

module Effective
  class Committee < ActiveRecord::Base
    self.table_name = (EffectiveCommittees.committees_table_name || :committees).to_s

    acts_as_slugged

    log_changes if respond_to?(:log_changes)
    has_rich_text :body

    has_many :committee_members, -> { Effective::CommitteeMember.sorted }, class_name: 'Effective::CommitteeMember', inverse_of: :committee, dependent: :delete_all
    accepts_nested_attributes_for :committee_members, allow_destroy: true

    has_many :committee_folders, -> { Effective::CommitteeFolder.sorted }, class_name: 'Effective::CommitteeFolder', inverse_of: :committee, dependent: :delete_all
    accepts_nested_attributes_for :committee_folders, allow_destroy: true

    has_many :committee_files, -> { Effective::CommitteeFile.sorted }, class_name: 'Effective::CommitteeFile', inverse_of: :committee, dependent: :delete_all
    accepts_nested_attributes_for :committee_files, allow_destroy: true

    effective_resource do
      title                     :string
      slug                      :string

      committee_members_count   :integer # Counter Cache
      committee_folders_count   :integer # Counter Cache
      committee_files_count     :integer # Counter Cache

      timestamps
    end

    scope :sorted, -> { order(:title) }
    scope :deep, -> { with_rich_text_body.includes(committee_members: [:user], committee_folders: [:committee_files, :rich_text_body]) }

    scope :for_dashboard, -> { where(display_on_dashboard: true) }
    scope :for_index, -> { where(display_on_index: true) }

    validates :title, presence: true, uniqueness: true, length: { maximum: 255 }

    def to_s
      title.presence || 'New Committee'
    end

    def committee_member(user:)
      committee_members.find { |member| member.user_id == user.id }
    end

    # Find or build
    def build_committee_member(user:)
      committee_member(user: user) || committee_members.build(user: user)
    end

    def users
      committee_members.reject(&:marked_for_destruction?).map(&:user)
    end

    def emails
      committee_members.reject(&:marked_for_destruction?).select(&:active?).map(&:email).compact.join(', ')
    end

    def children
      committee_folders
        .select { |folder| folder.committee_folder_id.blank? }
        .flat_map { |folder| [folder] + folder.children }
    end

  end
end
