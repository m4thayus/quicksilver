# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Engineer", type: :feature do
  before do
    login_as UserHelper.for_role(:engineer_user)
  end

  it "starts at the tasks page" do
    expect(page).to have_current_path tasks_path
  end

  it "shows the task list" do
    create_list(:task, 3)
    visit current_path

    expect(page.all("tr").size).to eq 3
  end

  it "creates new tasks" do
    visit tasks_path
    click_button "New Task"

    expect(page).to have_current_path new_task_path

    fill_in "title", with: "A new task"
    fill_in "description", with: "Task description"

    click_button "Create Task"

    expect(Task.count).to eq 1
    expect(Task.first.title).to eq "A new task"
    expect(Task.first.description).to eq "Task description"
  end
end
