# frozen_string_literal: true

module Effective
  class CommitteeMember < ActiveRecord::Base
    self.table_name = (EffectiveCommittees.committee_members_table_name || :committee_members).to_s

    attr_accessor :user_ids, :committee_ids

    acts_as_role_restricted
    log_changes(to: :committee) if respond_to?(:log_changes)

    belongs_to :committee, polymorphic: true, counter_cache: true
    belongs_to :user, polymorphic: true

    accepts_nested_attributes_for :committee
    accepts_nested_attributes_for :user

    effective_resource do
      roles_mask    :integer

      category      :string

      start_on      :date
      end_on        :date

      timestamps
    end

    scope :sorted, -> { order(:id) }
    scope :deep, -> { includes(:user, :committee) }

    before_validation(if: -> { user_ids.present? }) do
      assign_attributes(user_id: user_ids.first, user_ids: user_ids[1..-1])
    end

    before_validation(if: -> { committee_ids.present? }) do
      assign_attributes(committee_id: committee_ids.first, committee_ids: committee_ids[1..-1])
    end

    after_commit(if: -> { user_ids.present? }) do
      additional = (user_ids - CommitteeMember.where(committee_id: committee_id, user_id: user_ids).pluck(:user_id))
      additional = additional.map { |user_id| {committee_id: committee_id, committee_type: committee_type, user_id: user_id, user_type: user_type, roles_mask: roles_mask, start_on: start_on, end_on: end_on} }
      CommitteeMember.insert_all(additional)
    end

    after_commit(if: -> { committee_ids.present? }) do
      additional = (committee_ids - CommitteeMember.where(user_id: user_id, committee_id: committee_ids).pluck(:committee_id))
      additional = additional.map { |committee_id| {committee_id: committee_id, committee_type: committee_type, user_id: user_id, user_type: user_type, roles_mask: roles_mask, start_on: start_on, end_on: end_on} }
      CommitteeMember.insert_all(additional)
    end

    validates :committee, presence: true
    validates :user, presence: true

    validates :user_id, if: -> { user_id && user_type && committee_id && committee_type },
      uniqueness: { scope: [:committee_id, :committee_type], message: 'already belongs to this committee' }

    validate(if: -> { start_on && end_on }) do
      self.errors.add(:end_on, 'must be after start date') unless end_on > start_on
    end

    def to_s
      user.to_s
    end

    def active?(date: nil)
      return true if start_on.blank? && end_on.blank?

      date ||= Time.zone.now
      date = date.to_date if date.respond_to?(:to_date)

      (start_on..end_on).cover?(date)  # Endless ranges
    end

    def expired?(date: nil)
      active?(date: date) == false
    end

    def user_ids
      Array(@user_ids) - [nil, '']
    end

    def committee_ids
      Array(@committee_ids) - [nil, '']
    end

    def build_user(attributes = {})
      raise('please assign user_type first') if user_type.blank?
      self.user = user_type.constantize.new(attributes)
    end

    def build_committee(attributes = {})
      raise('please assign committee_type first') if committee_type.blank?
      self.committee = committee_type.constantize.new(attributes)
    end

  end
end
