# frozen_string_literal: true

module ViewUserHelper
  def without_verifying_partial_doubles
    verify = RSpec::Mocks.configuration.verify_partial_doubles?
    RSpec::Mocks.configuration.verify_partial_doubles = false if verify
    yield
    RSpec::Mocks.configuration.verify_partial_doubles = verify
  end
end
