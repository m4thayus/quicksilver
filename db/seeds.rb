# frozen_string_literal: true

(User::ADMINISTRATORS + User::ENGINEERS + User::MEMBERS + User::GUESTS).each do |email|
  User.create(name: email.split(/@/).first, email:, password: "password")
end
