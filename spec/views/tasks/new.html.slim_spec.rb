# frozen_string_literal: true

require "rails_helper"

RSpec.describe "tasks/new", type: :view do
  let(:user) { create(:engineer_user) }

  # def without_verifying_partial_doubles
  #   verify = RSpec::Mocks.configuration.verify_partial_doubles?
  #   RSpec::Mocks.configuration.verify_partial_doubles = false if verify
  #   yield
  #   RSpec::Mocks.configuration.verify_partial_doubles = verify
  # end

  # before do
  #   without_verifying_partial_doubles do
  #     allow(controller).to receive(:current_user).and_return(user)
  #   end
  # end

  before do
    assign(:task, build(:task))
  end

  describe "the new task form" do
    it "renders a name input" do
      render
      expect(rendered).to match(/input.*name="task\[title\]"/)
    end

    it "renders a description input", user: :engineer_user do
      render
      expect(rendered).to match(/textarea.*name="task\[description\]"/)
    end

    it "renders a submit button" do
      render
      expect(rendered).to match(/input.*type="submit"/)
    end
  end
end
