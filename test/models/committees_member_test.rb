require 'test_helper'

class CommitteesMemberTest < ActiveSupport::TestCase
  test 'committee member' do
    committee = build_committee()
    member = committee.committee_members.first

    assert member.valid?
  end

  test 'a user can hold multiple terms on the same committee' do
    committee = build_committee()
    user = create_user!

    # A past, expired term as chair
    past = committee.committee_members.build(user: user, start_on: Time.zone.now - 2.years, end_on: Time.zone.now - 1.year)

    # A current, active term as a regular member
    current = committee.committee_members.build(user: user)

    # No uniqueness validation blocks a user from belonging to the committee more than once
    assert past.valid?
    assert current.valid?

    assert_equal 2, committee.committee_members_for(user: user).count
    assert past.expired?
    assert current.active?

    # The active check resolves to the user's currently-active term
    assert_equal current, committee.committee_member(user: user)
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
