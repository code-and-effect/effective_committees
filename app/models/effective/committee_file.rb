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

      timestamps
    end

    before_validation do
      self.committee ||= committee_folder&.committee
    end

    before_validation(if: -> { file.attached? }) do
      self.title ||= file.filename.to_s
    end

    scope :deep, -> { with_attached_file.includes(:committee, :committee_folder) }
    scope :sorted, -> { order(:title) }

    validates :title, presence: true
    validates :file, presence: true

    def to_s
      title.presence || 'file'
    end

  end
end
