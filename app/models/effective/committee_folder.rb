# frozen_string_literal: true

module Effective
  class CommitteeFolder < ActiveRecord::Base
    self.table_name = (EffectiveCommittees.committee_folders_table_name || :committee_folders).to_s

    acts_as_slugged
    log_changes(to: :committee) if respond_to?(:log_changes)

    belongs_to :committee, polymorphic: true, counter_cache: true

    has_rich_text :body
    has_many :committee_files, -> { Effective::CommitteeFile.sorted.deep }, dependent: :destroy, inverse_of: :committee

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

    scope :deep, -> { includes(:committee, :committee_files) }
    scope :sorted, -> { order(:position) }

    validates :title, presence: true, length: { maximum: 250 },
      uniqueness: { scope: [:committee_id], message: 'already exists for this committee'}

    validates :position, presence: true

    def to_s
      title.presence || 'folder'
    end

  end
end
