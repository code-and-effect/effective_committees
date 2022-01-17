# frozen_string_literal: true

module Effective
  class Committee < ActiveRecord::Base
    self.table_name = EffectiveCommittees.committees_table_name.to_s

    acts_as_slugged
    log_changes if respond_to?(:log_changes)
    has_many_rich_texts

    has_many :committee_members, -> { Effective::CommitteeMember.sorted }, class_name: 'Effective::CommitteeMember', inverse_of: :committee, dependent: :delete_all
    accepts_nested_attributes_for :committee_members, allow_destroy: true

    effective_resource do
      title                     :string
      slug                      :string

      committee_members_count   :integer # Counter Cache

      timestamps
    end

    scope :sorted, -> { order(:title) }
    scope :deep, -> { includes(:committee_members) }

    validates :title, presence: true, uniqueness: true, length: { maximum: 255 }

    def to_s
      title.presence || 'New Committee'
    end

    def body
      rich_text_body
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

  end
end
