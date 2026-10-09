# Blog

A small blog application built with Phoenix and LiveView. It supports user authentication, blog post creation, likes, comments, and admin moderation in a real-time UI.

## Features

- User registration, login, and email confirmation flows
- Authenticated post creation for users
- Live-like interactions with post likes
- Commenting on individual posts
- Admin-only moderation panel to toggle post status between active and banned
- Real-time updates using Phoenix PubSub and LiveView subscriptions
- Styling with Tailwind CSS
- PostgreSQL persistence via Ecto

## Tech stack

- Elixir / Phoenix
- Phoenix LiveView
- Ecto + PostgreSQL
- Tailwind CSS
- Phoenix HTML + HEEx
- BCrypt for password hashing

## Project structure

```text
.
├── lib/
│   ├── blog/                 # Contexts and domain logic
│   ├── blog_web/             # Router, LiveViews, controllers, layouts
│   ├── blog.ex               # App module
│   └── blog_web.ex           # Web module
├── config/                   # Runtime and environment config
├── priv/                    # Database migrations, static assets, gettext
├── assets/                  # JS/CSS source files
├── test/                    # Tests
├── mix.exs                  # Elixir project config
├── mix.lock                 # Dependency lock file
├── README.md                # Project documentation
└── .gitignore
```

## Prerequisites

Before running the app, make sure you have:

- Elixir 1.14+
- Erlang/OTP
- PostgreSQL running locally
- A database user with access to a local development database

## Getting started

1. Install dependencies:

```bash
mix deps.get
```

2. Create and migrate the database:

```bash
mix ecto.create
mix ecto.migrate
```

3. Start the Phoenix server:

```bash
mix phx.server
```

4. Open the app in your browser:

```text
http://localhost:4000
```

## Environment configuration

The default development config uses a local PostgreSQL setup. If your local credentials differ, update the database settings in `config/dev.exs` or use environment variables in production.

For production, the app expects `DATABASE_URL` and `SECRET_KEY_BASE` to be set. See `config/runtime.exs` for the production setup.


## Learn more

- Phoenix docs: https://hexdocs.pm/phoenix
- LiveView docs: https://hexdocs.pm/phoenix_live_view
- Ecto docs: https://hexdocs.pm/ecto
