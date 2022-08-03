# frozen_string_literal: true

require "rails_helper"

RSpec.describe "tasks/index", type: :view do
  let(:tasks) do
    [0..2].map do
      create(:task) do |t|
        t.owner = create(:user)
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
      expect(rendered).to match(/#{tasks.first.owner.name}/)
    end
  end

  describe "the last task" do
    it "renders the title" do
      render
      expect(rendered).to match(/#{tasks.last.title}/)
    end

    it "renders the assignee" do
      render
      expect(rendered).to match(/#{tasks.last.owner.name}/)
    end
  end
end
