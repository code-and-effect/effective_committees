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

  test 'active? treats end_on as exclusive' do
    today = Date.current
    committee = create_committee()
    member = committee.committee_members.first

    # Member whose term ends today is no longer active today
    member.update!(start_on: today - 10.days, end_on: today)
    refute member.active?(date: today)

    # End date in the future — active today
    member.update!(start_on: today - 10.days, end_on: today + 1.day)
    assert member.active?(date: today)
  end

  test 'single-row end_on equals start_on is allowed' do
    committee = create_committee()
    member = committee.committee_members.first

    member.start_on = Date.current
    member.end_on = Date.current
    assert member.valid?
  end

  test 'single-row end_on before start_on is invalid' do
    committee = create_committee()
    member = committee.committee_members.first

    member.start_on = Date.current
    member.end_on = Date.current - 1.day
    refute member.valid?
    assert member.errors[:end_on].present?
  end

  test 'non-overlapping terms for same user on same committee are allowed' do
    committee = create_committee()
    user = committee.committee_members.first.user

    committee.committee_members.first.update!(start_on: Date.new(2020, 1, 1), end_on: Date.new(2022, 12, 31))

    second_term = committee.committee_members.build(user: user, start_on: Date.new(2024, 1, 1), end_on: Date.new(2026, 12, 31))
    assert second_term.valid?
  end

  test 'same-day handoff terms are allowed' do
    committee = create_committee()
    user = committee.committee_members.first.user

    committee.committee_members.first.update!(start_on: Date.new(2020, 1, 1), end_on: Date.new(2024, 6, 30))

    adjacent = committee.committee_members.build(user: user, start_on: Date.new(2024, 6, 30), end_on: Date.new(2026, 12, 31))
    assert adjacent.valid?
  end

  test 'overlapping terms for the same user on the same committee are allowed' do
    committee = create_committee()
    user = committee.committee_members.first.user

    first_term = committee.committee_members.first
    first_term.update!(start_on: Date.new(2024, 1, 1), end_on: Date.new(2026, 12, 31))

    overlapping = committee.committee_members.create!(user: user, start_on: Date.new(2024, 6, 30), end_on: Date.new(2026, 12, 31))

    assert first_term.active?(date: Date.new(2025, 1, 1))
    assert overlapping.active?(date: Date.new(2025, 1, 1))
    assert_equal 2, committee.reload.committee_members.select { |member| member.active?(date: Date.new(2025, 1, 1)) && member.user_id == user.id }.count
    assert_equal 2, committee.reload.committee_members_for(user: user).count
  end

  test 'open-ended terms can overlap for the same user on the same committee' do
    committee = create_committee()
    user = committee.committee_members.first.user

    duplicate = committee.committee_members.create!(user: user)

    assert committee.committee_members.first.active?
    assert duplicate.active?
    assert_equal 2, committee.reload.committee_members_for(user: user).count
  end

  test 'editing an existing term remains valid' do
    committee = create_committee()
    member = committee.committee_members.first

    member.start_on = Date.new(2020, 1, 1)
    member.end_on = Date.new(2022, 12, 31)
    assert member.valid?
  end

  test 'committee.committee_member returns the currently active term' do
    committee = create_committee()
    member = committee.committee_members.first
    user = member.user

    member.update!(start_on: Date.new(2020, 1, 1), end_on: Date.new(2022, 12, 31))
    active = committee.committee_members.create!(user: user, start_on: Date.new(2024, 1, 1))

    committee.reload
    assert_equal active.id, committee.committee_member(user: user).id
  end

  test 'committee.committee_member returns nil when all terms are expired' do
    committee = create_committee()
    member = committee.committee_members.first
    user = member.user

    member.update!(start_on: Date.new(2020, 1, 1), end_on: Date.new(2022, 12, 31))

    committee.reload
    assert_nil committee.committee_member(user: user)
  end

  test 'committee.committee_members_for returns full history' do
    committee = create_committee()
    member = committee.committee_members.first
    user = member.user

    member.update!(start_on: Date.new(2020, 1, 1), end_on: Date.new(2022, 12, 31))
    committee.committee_members.create!(user: user, start_on: Date.new(2024, 1, 1))

    committee.reload
    assert_equal 2, committee.committee_members_for(user: user).length
  end

end
