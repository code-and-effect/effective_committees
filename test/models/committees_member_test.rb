require 'test_helper'

class CommitteesMemberTest < ActiveSupport::TestCase
  test 'committee member' do
    committee = build_committee()
    member = committee.committee_members.first

    assert member.valid?
  end

  test 'committee member active?' do
    committee = build_committee()
    member = committee.committee_members.first

    # Active when no start or end date
    assert member.start_on.nil?
    assert member.end_on.nil?
    assert member.active?

    # Valid Start Date
    member.start_on = Time.zone.now
    assert member.active?

    # Start date in the future
    member.start_on = Time.zone.now + 1.day
    refute member.active?

    # Valid End Date
    member.start_on = nil
    member.end_on = Time.zone.now + 1.day
    assert member.active?

    # End date in the past
    member.end_on = Time.zone.now - 1.day
    refute member.active?

    # Range
    member.start_on = Time.zone.now - 1.day
    member.end_on = Time.zone.now + 1.day
    assert member.active?

    # Range
    member.start_on = Time.zone.now + 1.day
    member.end_on = Time.zone.now + 10.day
    refute member.active?
  end

end
