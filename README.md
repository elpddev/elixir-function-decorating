# Elixir Function Decorator

A function declaration decorator macro for Elixir. Used mainly for adding log statements to the function calls.

This macro is based mainly on:

* The work of [Saša Jurić](https://github.com/sasa1977)
on the [Elixir macro articles](http://www.theerlangelist.com/article/macros_1). Especially the mechanism for extracting function definition metadata.
* The solution from him for [how to override the def macro in Elixir](https://gist.github.com/sasa1977/a14f8dd76fe437668ac1)

All I did was use the two, add some minor adjustment for my needs and package it as an helper module.

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

Normal usage

```elixir
defmodule User do
  use FunctionDecorating

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

Disable log in a specific module:

```elixir
defmodule User do
  use FunctionDecorating skip_log: true

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

The module is also configured to skip the function decoration
when Mix.env != :dev

When Mix.env == :prod

```elixir
defmodule User do
  use FunctionDecorating

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

When Mix.env == :prod and user excplicitly enable log decoration

```elixir
defmodule User do
  use FunctionDecorating skip_log: false

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
