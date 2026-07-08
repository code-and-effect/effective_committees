# frozen_string_literal: true

module Effective
  class Committee < ActiveRecord::Base
    self.table_name = (EffectiveCommittees.committees_table_name || :committees).to_s

    acts_as_slugged

    log_changes if respond_to?(:log_changes)
    has_rich_text :body

    has_many :committee_members, -> { Effective::CommitteeMember.sorted }, class_name: 'Effective::CommitteeMember', inverse_of: :committee, dependent: :delete_all
    accepts_nested_attributes_for :committee_members, allow_destroy: true


    has_many :committee_folders, -> { Effective::CommitteeFolder.sorted }, class_name: 'Effective::CommitteeFolder', inverse_of: :committee, dependent: :destroy
    accepts_nested_attributes_for :committee_folders, allow_destroy: true

    has_many :committee_files, -> { Effective::CommitteeFile.sorted }, class_name: 'Effective::CommitteeFile', inverse_of: :committee, dependent: :destroy
    accepts_nested_attributes_for :committee_files, allow_destroy: true

    has_many :committee_agenda_items, -> { Effective::CommitteeAgendaItem.sorted }, class_name: 'Effective::CommitteeAgendaItem', inverse_of: :committee, dependent: :delete_all

    effective_resource do
      title                     :string
      slug                      :string

      position                  :integer

      committee_members_count   :integer # Counter Cache
      committee_folders_count   :integer # Counter Cache
      committee_files_count     :integer # Counter Cache

      agenda_mode               :boolean

      timestamps
    end

    scope :sorted, -> { order(:position) }
    scope :deep, -> { with_rich_text_body.includes(committee_members: [:user], committee_folders: [:committee_files, :rich_text_body]) }

    scope :for_dashboard, -> { where(display_on_dashboard: true) }
    scope :for_index, -> { where(display_on_index: true) }

    before_validation do
      self.position ||= (self.class.maximum(:position) || -1) + 1
    end

    validates :title, presence: true, uniqueness: true, length: { maximum: 255 }
    validates :position, presence: true

    def to_s
      title.presence || 'New Committee'
    end

    # Returns the user's currently-active term on this committee, or nil.
    # For the full history including expired terms, use committee_members_for(user:).
    def committee_member(user:)
      committee_members.find { |cm| cm.user_id == user.id && cm.active? }
    end

    # All terms (active and expired) a user has served on this committee.
    # Do not add uniq here
    def committee_members_for(user:)
      committee_members.select { |cm| cm.user_id == user.id }
    end

    # Find-active-or-build-new. If the user has no active term, build a fresh row
    # (expired terms are history and are not edited in place through this helper).
    def build_committee_member(user:)
      committee_member(user: user) || committee_members.build(user: user)
    end

    def users
      committee_members.map(&:user).uniq
    end

    def emails
      committee_members.select(&:active?).map(&:email).compact.uniq.join(', ')
    end

    def children
      committee_folders
        .select { |folder| folder.committee_folder_id.blank? }
        .flat_map { |folder| [folder] + folder.children }
    end

  end
end
