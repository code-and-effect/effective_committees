require 'test_helper'

class CommitteesTest < ActiveSupport::TestCase
  test 'user' do
    user = build_user()
    assert user.valid?
  end

  test 'committee' do
    committee = build_committee()
    assert committee.valid?

    assert_equal 2, committee.committee_members.length
  end

end
