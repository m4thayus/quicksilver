# frozen_string_literal: true

module Mcp
  module Errors
    class Base < StandardError
      attr_reader :code, :data

      def initialize(message, code:, data: nil)
        super(message)
        @code = code
        @data = data
      end
    end

    class ParseError < Base
      def initialize(message = "Parse error")
        super(message, code: -32_700)
      end
    end

    class InvalidRequest < Base
      def initialize(message = "Invalid Request")
        super(message, code: -32_600)
      end
    end

    class MethodNotFound < Base
      def initialize(message = "Method not found")
        super(message, code: -32_601)
      end
    end

    class InvalidParams < Base
      def initialize(message = "Invalid params", data: nil)
        super(message, code: -32_602, data:)
      end
    end

    class ResourceNotFound < Base
      def initialize(message = "Resource not found", data: nil)
        super(message, code: -32_002, data:)
      end
    end
  end
end
