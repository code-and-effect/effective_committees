namespace :effective_committees do

  # bundle exec rake effective_committees:seed
  task seed: :environment do
    load "#{__dir__}/../../db/seeds.rb"
  end

end
