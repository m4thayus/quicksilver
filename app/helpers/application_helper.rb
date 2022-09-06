# frozen_string_literal: true

module ApplicationHelper
  def markdown
    @markdown ||= begin
                    opts = optionize(%i[with_toc_data hard_wrap gh_blockcode])
                    opts[:link_attributes] = { target: "_blank" }
                    renderer = Redcarpet::Render::HTML.new(opts)
                    Redcarpet::Markdown.new(renderer, optionize(%i[no_intra_emphasis autolink underline fenced_code_blocks tables strikethrough space_after_headers]))
                  end
  end

  def optionize(options)
    options.each_with_object({}) { |option, memo| memo[option] = true }
  end
end
