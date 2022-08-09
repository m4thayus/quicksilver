# frozen_string_literal: true

require "rails_helper"

RSpec.describe "tasks/show", type: :view do
  let(:task) do
    create(:task) do |t|
      t.owner = create(:user)
    end
  end

  before do
    assign(:task, task)
  end

  it "renders the title" do
    render
    expect(rendered).to match(/#{task.title}/)
  end

  it "renders the assignee" do
    render
    expect(rendered).to match(/#{task.owner.name}/)
  end

  it "renders the description" do
    render
    expect(rendered).to match(/#{task.description}/)
  end

  it "renders an edit button" do
    render
    expect(rendered).to match(%r{<button.*>Edit Task</button>})
  end
end
