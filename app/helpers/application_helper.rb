# frozen_string_literal: true

module ApplicationHelper
  def markdown
    @markdown ||= begin
                    renderer = Redcarpet::Render::HTML.new(link_attributes: { target: "_blank" })
                    Redcarpet::Markdown.new(renderer, no_intra_emphasis: true, autolink: true, underline: true)
                  end
  end
end
