# frozen_string_literal: true

module Effective
  class CommitteeMember < ActiveRecord::Base
    attr_accessor :new_committee_member_user_action
    acts_as_role_restricted

    log_changes(to: :committee) if respond_to?(:log_changes)

    belongs_to :committee, polymorphic: true, counter_cache: true
    belongs_to :user, polymorphic: true

    accepts_nested_attributes_for :committee
    accepts_nested_attributes_for :user

    effective_resource do
      roles_mask    :integer

      timestamps
    end

    scope :sorted, -> { order(:id) }
    scope :deep, -> { includes(:user, :committee) }

    before_validation(if: -> { user && user.new_record? }) do
      user.password ||= SecureRandom.base64(12) + '!@#123abcABC-'
    end

    validates :committee, presence: true
    validates :user, presence: true

    validates :user_id, if: -> { user_id && user_type && committee_id && committee_type },
      uniqueness: { scope: [:committee_id, :committee_type], message: 'already belongs to this committee' }

    def to_s
      user.to_s
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
