# frozen_string_literal: true

require "rails_helper"

RSpec.describe "tasks/new", type: :view do
  describe "the new task form" do
    it "renders a name input" do
      render
      expect(rendered).to match(/input.*name="task\[title\]"/)
    end

    it "renders a descrition input" do
      render
      expect(rendered).to match(/textarea.*name="task\[description\]"/)
    end

    it "renders a submit button" do
      render
      expect(rendered).to match(/input.*type="submit"/)
    end
  end
end
