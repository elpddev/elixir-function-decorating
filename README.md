# ElixirLogflow

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add elixir_logflow to your list of dependencies in `mix.exs`:

        def deps do
          [{:elixir_logflow, "~> 0.0.1"}]
        end

  2. Ensure elixir_logflow is started before your application:

        def application do
          [applications: [:elixir_logflow]]
        end

## Usage

Normal usage.

```elixir
defmodule User do
  use ElixirLogflow

  def say_hello do
    IO.puts "halloa!"
  end
end
```

Will result in

```elixir
defmodule User do
  # ...

  def say_hello do
    do_log
    IO.puts "halloa!"
  end
end
```

Disable log in module.

```elixir
defmodule User do
  use ElixirLogflow skip_log: true

  def say_hello do
    IO.puts "halloa!"
  end
end
```

```elixir
defmodule User do

  # ...

  def say_hello do
    IO.puts "halloa!"
  end
end
```
