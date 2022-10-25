# frozen_string_literal: true

namespace :wishlist do
  desc "Move approved tasks from wishlist to main board"
  task promote: :environment do
    include ActionView::Helpers::TextHelper

    n = Board.wishlist
             .tasks
             .approved
             .update_all(board_id: nil, owner_id: nil, approved: false) # rubocop:disable Rails/SkipsModelValidations

    puts "#{pluralize(n, 'task')} promoted"
  end
end
