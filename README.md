# Elixir Function Decorator

A function decorator macro for Elixir. Used mainly for adding log statements to the function calls.

This project is based mainly on:

* The work of [Saša Jurić](https://github.com/sasa1977)
on the [Elixir macro articles](http://www.theerlangelist.com/article/macros_1). Especially the mechanism for extracting function definition metadata.
* The solution from him for [how to override the def macro in Elixir](https://gist.github.com/sasa1977/a14f8dd76fe437668ac1)
* An addition made by [Björn Rochel](https://github.com/BjRo) to the adef macro considering default values for arguments.

## Motivation

All I did was use the solution provided by the mentioned above, add some minor refactoring and adjustments for my needs and package it as an helper module.

This was a learning project getting into Elixir macros field.

For getting into Elixir Macros, you are encourgae to read [Saša Jurić](https://github.com/sasa1977)
's excellent [Elixir macro articles series](http://www.theerlangelist.com/article/macros_1)

## State
- Currently in alpha stage.
- Not intended to be used in production. Only for experiments.
- For logging, one can use other means like trace.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add function_decorating to your list of dependencies in `mix.exs`:

        def deps do
          [{:function_decorating, "~> 0.0.1"}]
        end

  2. Ensure function_decorating is started before your application:

        def application do
          [applications: [:function_decorating]]
        end

## Usage

Decorating in dev with log decorator.

```elixir
defmodule User do
  use FunctionDecorating
  decorate_fn_with(LogDecorator)

  def say(word) do
    word
  end
end
```

```elixir
iex>User.say("hello")
#PID<0.86.0> [x] Elixir.User.say(["hello"]) -> "hello"
"hello"
```

Default usage is for Mix.env == :dev only. To override it:

```elixir
defmodule User do
  use FunctionDecorating mix_envs: [:test]
  decorate_fn_with(LogDecorator)

  def say(word) do
    word
  end
end
```

```elixir
iex >Mix.env
:test

iex >User.say("hello")
#PID<0.86.0> [x] Elixir.User.say(["hello"]) -> "hello"
"hello"
```
