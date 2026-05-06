# frozen_string_literal: true

module Effective
  class CommitteeFolder < ActiveRecord::Base
    self.table_name = (EffectiveCommittees.committee_folders_table_name || :committee_folders).to_s

    acts_as_slugged
    log_changes(to: :committee) if respond_to?(:log_changes)

    belongs_to :committee, polymorphic: true, counter_cache: true
    belongs_to :committee_folder, optional: true

    has_rich_text :body
    has_many :committee_folders, -> { Effective::CommitteeFolder.sorted.deep }, dependent: :destroy, inverse_of: :committee_folder
    has_many :committee_files, -> { Effective::CommitteeFile.sorted.deep }, dependent: :destroy, inverse_of: :committee_folder

    has_many :committee_agenda_items, -> { Effective::CommitteeAgendaItem.sorted }, dependent: :destroy, inverse_of: :committee_folder

    has_many_attached :files

    effective_resource do
      title         :string
      slug          :string

      position                :integer
      committee_files_count   :integer # Counter Cache

      meeting_date    :datetime

      timestamps
    end

    before_validation(if: -> { committee.present? }) do
      self.position ||= (committee.committee_folders.map { |obj| obj.position }.compact.max || -1) + 1
    end

    scope :deep, -> { includes(:rich_text_body, :committee, :committee_files) }
    scope :sorted, -> { order(:position) }
    scope :top_level, -> { where(committee_folder_id: nil) }
    scope :upcoming_meetings, -> { where.not(meeting_date: nil).where('meeting_date >= ?', 1.week.ago.beginning_of_day).order(:meeting_date) }
    scope :past_meetings,     -> { where.not(meeting_date: nil).where('meeting_date < ?',  1.week.ago.beginning_of_day).order(meeting_date: :desc) }

    # Hierarchical alphabetical sort: roots A→Z, then each root's children A→Z, etc.
    # Returns an Array so it can't be chained further; intended for select dropdowns.
    scope :sorted_for_dropdowns, -> {
      folders = order(:title).to_a
      by_parent = folders.group_by(&:committee_folder_id)
      visible_ids = folders.map(&:id).to_set

      result = []
      walk = ->(parent_id) {
        Array(by_parent[parent_id]).each do |folder|
          result << folder
          walk.call(folder.id)
        end
      }
      walk.call(nil)

      # Any folders whose parent isn't in the current scope (e.g. the relation
      # was filtered) should still appear, attached at the top in alphabetical order.
      orphans = folders.reject { |folder| result.include?(folder) }
                       .reject { |folder| visible_ids.include?(folder.committee_folder_id) }
      orphans.each do |folder|
        result << folder
        walk.call(folder.id)
      end

      result
    }

    validates :title, presence: true, length: { maximum: 250 },
      uniqueness: { scope: [:committee_id, :committee_folder_id], message: 'already exists in this folder' }

    validates :position, presence: true

    validate(if: -> { meeting_date.present? }) do
      if parents.any?(&:meeting?)
        errors.add(:meeting_date, "can't be set — a parent folder is already an agenda")
      end

      if persisted? && committee_folders.any? { |child| child.meeting_date.present? || child.send(:any_descendant_meeting?) }
        errors.add(:meeting_date, "can't be set — a child folder is already an agenda")
      end
    end

    def to_s
      (parents + [self]).map { |folder| (folder.title || 'folder') }.join(' / ')
    end

    def bulk_upload!
      files.each { |file| committee_files.create(file: file.blob) }
      true
    end

    def top_level?
      committee_folder.blank?
    end

    def meeting?
      meeting_date.present?
    end

    def agenda_section?
      committee_folder&.meeting?
    end

    def parent
      committee_folder || committee
    end

    def parents
      folder = self
      parents = []

      while folder.committee_folder.present?
        parents << folder.committee_folder
        folder = folder.committee_folder
      end

      parents.reverse
    end

    def children
      committee_folders.flat_map { |folder| [folder] + folder.children }
    end

    protected

    def any_descendant_meeting?
      committee_folders.any? { |child| child.meeting_date.present? || child.any_descendant_meeting? }
    end

  end
end
