# frozen_string_literal: true

namespace :users do
  desc "Creates new users from lists of admins, engineers, and members"
  task create: :environment do
    (User::ADMINISTRATORS + User::ENGINEERS + User::MEMBERS + User::GUESTS).each do |email|
      User.where(email:).first_or_create(name: email.split(/@/).first, password: "password") do |user|
        puts "Added user: #{user.name}"
      end
    end
  end
end
