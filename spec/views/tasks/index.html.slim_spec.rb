# frozen_string_literal: true

require "rails_helper"

RSpec.describe "tasks/index", type: :view do
  let(:tasks) do
    [0..2].map do
      create(:task) do |t|
        create(:assignee, task: t)
      end
    end
  end

  before do
    assign(:tasks, tasks)
  end

  describe "the first task" do
    it "renders the title" do
      render
      expect(rendered).to match(/#{tasks.first.title}/)
    end

    it "renders the assignee" do
      render
      expect(rendered).to match(/#{tasks.first.assignees.first.user.name}/)
    end
  end

  describe "the last task" do
    it "renders the title" do
      render
      expect(rendered).to match(/#{tasks.last.title}/)
    end

    it "renders the assignee" do
      render
      expect(rendered).to match(/#{tasks.last.assignees.first.user.name}/)
    end
  end
end
