# frozen_string_literal: true

require "rails_helper"

RSpec.describe "tasks/edit", type: :view do
  let(:task) { create(:task) }

  before do
    assign(:task, task)
  end

  describe "the edit task form" do
    it "renders a name input" do
      render
      expect(rendered).to match(/input.*name="task\[title\]"/)
    end

    it "renders the name value" do
      render
      expect(rendered).to match(/value="#{task.title}"/)
    end

    it "renders a description input" do
      render
      expect(rendered).to match(/textarea.*name="task\[description\]"/)
    end

    it "renders the description value" do
      render
      expect(rendered).to match(%r{<textarea.*>\s*#{task.description}\s*</textarea>})
    end

    it "renders a submit button" do
      render
      expect(rendered).to match(/input.*type="submit"/)
    end
  end
end
