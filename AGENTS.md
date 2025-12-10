# Repository Guidelines

## Project Structure & Module Organization
- Rails 7 app with primary code in `app/` (`models`, `controllers`, `views`, `helpers`, `javascript`). Slim templates live under `app/views`.
- Frontend bundles are built from `app/javascript` into `app/assets/builds`; static assets live in `app/assets` and `public/`.
- Domain specs sit in `spec/` with factories in `spec/factories`; support helpers under `spec/support`.
- Database migrations reside in `db/migrate`; seeds go in `db/seeds.rb`.

## Build, Test, and Development Commands
- `bin/setup` — install Ruby gems, yarn packages, and prepare the database for local development.
- `bin/dev` — run the app with the Procfile (Rails server, CSS/JS builds, etc.) for interactive development.
- `bin/rails db:migrate` — run pending migrations; use `RAILS_ENV=test` for test DB.
- `bin/rspec` — execute the test suite; add `SPEC_OPTS='--format documentation'` when debugging.
- `yarn build` — bundle frontend assets via esbuild into `app/assets/builds`.

## Coding Style & Naming Conventions
- Ruby: follow RuboCop defaults (`bin/rubocop`); 2-space indentation, snake_case methods/vars, CamelCase classes/modules.
- Slim views: lint with `bin/slim-lint`; keep logic minimal in templates.
- Stimulus controllers and JS modules: use PascalCase class names and kebab-case filenames (e.g., `app/javascript/controllers/comment_form_controller.js`).
- Prefer POROs or service objects in `app/` over fat controllers; keep specs close to the behavior they cover.

## Testing Guidelines
- Framework: RSpec with Capybara for system/feature coverage; factories via FactoryBot.
- Naming: mirror app paths (e.g., `spec/models/user_spec.rb`, `spec/requests/projects_spec.rb`).
- Use DatabaseCleaner or transactional fixtures as configured; reset state between examples.
- Aim for fast, isolated examples; add system specs only when user flows are critical.

## Commit & Pull Request Guidelines
- Commits: concise, imperative subjects (e.g., “Add project audit hook”); group related changes.
- Hooks: `lefthook` runs `bin/rubocop` and `bin/slim-lint` on commit, and `bin/brakeman`, `bin/bundle-audit check --update`, `bin/rspec` on push—keep the tree clean.
- PRs: summarize scope and motivation, list key changes, link issues/tickets, and include screenshots for UI changes; note migrations or configuration steps for reviewers.
- Add tests with behavior changes; mention coverage gaps or follow-ups explicitly.
