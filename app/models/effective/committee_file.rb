# frozen_string_literal: true

module Effective
  class CommitteeFile < ActiveRecord::Base
    self.table_name = (EffectiveCommittees.committee_files_table_name || :committee_files).to_s

    log_changes(to: :committee) if respond_to?(:log_changes)

    belongs_to :committee, polymorphic: true, counter_cache: true
    belongs_to :committee_folder, counter_cache: true

    has_one_attached :file

    effective_resource do
      title         :string
      notes         :text

      file_id          :integer
      file_created_at  :datetime

      position        :integer

      timestamps
    end

    before_validation(if: -> { committee_folder.present? }) do
      self.committee ||= committee_folder.committee
      self.position ||= (committee_folder.committee_files.map { |obj| obj.position }.compact.max || -1) + 1
    end

    before_validation(if: -> { file.attached? }) do
      assign_attributes(title: file.filename.to_s, file_id: file.attachment.blob.id, file_created_at: file.attachment.blob.created_at)
    end

    scope :deep, -> { with_attached_file.includes(:committee, :committee_folder) }
    scope :sorted, -> { order(:position) }

    validates :title, presence: true
    validates :file, presence: true
    validates :position, presence: true, if: -> { committee_folder.present? }

    def to_s
      title.presence || 'file'
    end

  end
end
