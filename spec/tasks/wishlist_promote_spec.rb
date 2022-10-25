# frozen_string_literal: true

require "rails_helper"

RSpec.describe "wishlist:promote", type: :task do
  let!(:wishlist) { create(:wishlist) }
  let!(:user) { create(:user) }
  let!(:wishlist_item) { create(:task, owner: user, approved: true, board: Board.wishlist) }

  before do
    create(:task, owner: user)
    create(:task, owner: user, board: wishlist)
    create(:task, owner: user, approved: true)
  end

  around do |example|
    if example.metadata[:stdout]
      example.run
    else
      original_stdout = $stdout
      # rubocop:disable RSpec/ExpectOutput
      $stdout = StringIO.new
      example.run
      $stdout = original_stdout
      # rubocop:enable RSpec/ExpectOutput
    end
  end

  it "outputs the number of tasks promoted", stdout: true do
    expect { task.invoke }
      .to output("1 task promoted\n").to_stdout
  end

  it "moves approved tasks from the wishlist" do
    expect { task.invoke }
      .to change { Board.wishlist.tasks.count }.by(-1)
  end

  it "moves approved tasks to the main board" do
    expect { task.invoke }
      .to change { wishlist_item.reload.board }.from(wishlist).to(nil)
  end

  it "clears the approved flag for moved tasks" do
    expect { task.invoke }
      .to change { wishlist_item.reload.approved }.from(true).to(false)
  end

  it "makes the task un-owned" do
    expect { task.invoke }
      .to change { wishlist_item.reload.owner }.from(user).to(nil)
  end
end
