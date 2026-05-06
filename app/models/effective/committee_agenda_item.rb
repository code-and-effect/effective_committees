# frozen_string_literal: true

module Effective
  class CommitteeAgendaItem < ActiveRecord::Base
    self.table_name = (EffectiveCommittees.committee_agenda_items_table_name || :committee_agenda_items).to_s

    log_changes(to: :committee) if respond_to?(:log_changes)

    belongs_to :committee, polymorphic: true
    belongs_to :committee_folder

    has_rich_text :body

    effective_resource do
      code        :string
      title       :string
      presenter   :string
      timed_at    :string

      position    :integer

      timestamps
    end

    before_validation(if: -> { committee_folder.present? }) do
      self.committee ||= committee_folder.committee
      self.position  ||= (committee_folder.committee_agenda_items.maximum(:position) || -1) + 1
    end

    scope :sorted, -> { order(:position) }
    scope :deep,   -> { includes(:rich_text_body) }

    validates :title, presence: true, length: { maximum: 250 }
    validates :position, presence: true
    validates :code, length: { maximum: 50 }
    validates :presenter, length: { maximum: 250 }
    validates :timed_at, length: { maximum: 250 }

    def to_s
      [code, title].compact_blank.join(' ').presence || model_name.human
    end
  end
end
