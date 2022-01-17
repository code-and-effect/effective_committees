# Effective Committees

Committees are groups of users that can all share files.

## Getting Started

This requires Rails 6+ and Twitter Bootstrap 4 and just works with Devise.

Please first install the [effective_datatables](https://github.com/code-and-effect/effective_datatables) gem.

Please download and install the [Twitter Bootstrap4](http://getbootstrap.com)

Add to your Gemfile:

```ruby
gem 'haml-rails' # or try using gem 'hamlit-rails'
gem 'effective_committees'
```

Run the bundle command to install it:

```console
bundle install
```

Then run the generator:

```ruby
rails generate effective_committees:install
```

The generator will install an initializer which describes all configuration options and creates a database migration.

If you want to tweak the table names, manually adjust both the configuration file and the migration now.

Then migrate the database:

```ruby
rake db:migrate
```

Please add the following to your User model:

```
effective_committees_user

Use the following datatables to display to your user their applicants dues:

```haml
%h2 My Committees
- datatable = EffectiveCommitteesDatatable.new(self)
```

and

```
Add a link to the admin menu:

```haml
- if can? :admin, :effective_committees
  - if can? :index, Effective::Committee
    = nav_link_to 'Committees', effective_committees.admin_committees_path
```

## Configuration

## Authorization

All authorization checks are handled via the effective_resources gem found in the `config/initializers/effective_resources.rb` file.

## Effective Roles

This gem works with effective roles for the representative roles.

Configure your `config/initializers/effective_roles.rb` something like this:

```
EffectiveRoles.setup do |config|
  config.roles = [:admin, :reserved, :owner, :billing] # Only add to the end of this array. Never prepend roles.

  # config.role_descriptions
  # ========================
  # This setting configures the text that is displayed by form helpers (see README.md)

  config.role_descriptions = {
    'User' => {
      # User roles
      admin: 'can log in to the /admin section of the website. full access to everything.',
    },
    'Effective::Representative' => {
      owner: 'the owner. full access to everything.',
      billing: 'the billing contact. full access to everything.'
    }
  }

  # config.assignable_roles
  # Which roles can be assigned by whom
  # =======================
  # When current_user is passed into a form helper function (see README.md)
  # this setting determines which roles that current_user may assign
  config.assignable_roles = {
    'User' => { admin: [:admin] },

    'Effective::Representative' => {
      admin: [:owner, :billing],
      owner: [:owner, :billing],
      billing: [:billing]
    }
  }
end
```

## Permissions

The permissions you actually want to define are as follows (using CanCan):

```ruby
# if user.persisted?
#   can :index, Effective::Committee
#   can(:show, Effective::Committee) { |committee| user.committees.include?(committee) }

#   can([:edit, :update], Effective::Committee) do |committee|
#     rep = user.representative(committee: committee)
#     rep && (rep.is?(:owner) || rep.is?(:billing))
#   end

#   can :index, Effective::Representative
#   can(:new, Effective::Representative)

#   can([:create, :edit, :update], Effective::Representative) do |representative|
#     rep = user.representative(committee: representative.committee)
#     rep && (rep.is?(:owner) || rep.is?(:billing))
#   end

#   can(:destroy, Effective::Representative) do |representative|
#     allowed = !(representative.is?(:owner) || representative.is?(:billing))
#     rep = user.representative(committee: representative.committee)

#     allowed && rep && (rep.is?(:owner) || rep.is?(:billing))
#   end
# end

# if user.admin?
#   can :admin, :effective_committees
#   can(crud, Effective::Committee)

#   can(crud - [:destroy], Effective::Representative)
#   can(:destroy, Effective::Representative) { |rep| !rep.is?(:owner) }
# end
```

## License

MIT License.  Copyright [Code and Effect Inc.](http://www.codeandeffect.com/)

## Testing

Run tests by:

```ruby
rails test
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Bonus points for test coverage
6. Create new Pull Request
