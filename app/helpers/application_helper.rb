# frozen_string_literal: true

module ApplicationHelper
  DEFAULT_NAME = "default"

  def authorized_users
    User.all.pluck(:name, :id)
  end

  def board_options
    boards = Board.all.pluck(:name, :id)
    boards << [DEFAULT_NAME, nil]
  end

  def markdown
    @markdown ||= begin
                    opts = optionize(%i[with_toc_data hard_wrap gh_blockcode])
                    opts[:link_attributes] = { target: "_blank" }
                    renderer = Redcarpet::Render::HTML.new(opts)
                    Redcarpet::Markdown.new(renderer, optionize(%i[no_intra_emphasis autolink underline fenced_code_blocks tables strikethrough space_after_headers]))
                  end
  end

  def optionize(options)
    options.index_with { true }
  end
end
