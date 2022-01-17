module EffectiveCommitteesTestBuilder

  def create_user!
    build_user.tap { |user| user.save! }
  end

  def build_user
    @user_index ||= 0
    @user_index += 1

    User.new(
      email: "user#{@user_index}@example.com",
      password: 'rubicon2020',
      password_confirmation: 'rubicon2020',
      first_name: 'Test',
      last_name: 'User'
    )
  end

  def create_committee
    build_committee().tap { |committee| committee.save! }
  end

  def build_committee
    now = Time.zone.now

    committee = Effective::Committee.new(title: "Main Committee")

    committee.committee_members.build(user: build_user)
    committee.committee_members.build(user: build_user)

    committee
  end

end
