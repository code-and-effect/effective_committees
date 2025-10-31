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

    has_many_attached :files

    effective_resource do
      title         :string
      slug          :string

      position                :integer
      committee_files_count   :integer # Counter Cache

      timestamps
    end

    before_validation(if: -> { committee.present? }) do
      self.position ||= (committee.committee_folders.map { |obj| obj.position }.compact.max || -1) + 1
    end

    scope :deep, -> { includes(:rich_text_body, :committee, :committee_files) }
    scope :sorted, -> { order(:position) }

    validates :title, presence: true, length: { maximum: 250 },
      uniqueness: { scope: [:committee_id], message: 'already exists for this committee'}

    validates :position, presence: true

    def to_s
      (parents + [self]).map { |folder| (folder.title || 'folder') }.join(' / ')
    end

    def bulk_upload!
      files.each { |file| committee_files.create(file: file.blob) }
      true
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

  end
end
