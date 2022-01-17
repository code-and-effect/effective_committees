require 'test_helper'

class CommitteesTest < ActiveSupport::TestCase
  test 'committee user' do
    user = build_user()
    assert user.valid?
  end

end
