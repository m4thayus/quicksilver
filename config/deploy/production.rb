# frozen_string_literal: true

set :default_env, { path: "$HOME/.npm-global/bin:$PATH" }

server "quicksilver.us-east-1", user: "deployer", roles: %w[web app db]
