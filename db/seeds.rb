# frozen_string_literal: true

(User::ADMINISTRATORS + User::ENGINEERS).each do |email|
  User.create(name: email.split(/@/).first, email: email, password: "password")
end
