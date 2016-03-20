defmodule ElixirLogflow do
  @moduledoc """
  defmodule User do
    use ElixirLogflow

    def say(word) do
      word
    end
  end

  # todo: no decoration is happening

  defmodule User do
    use ElixirLogflow
    decorate_fn_with: LogDecorator

    def say(word) do
      word
    end
  end

  # todo: decoration result ast

  # todo: result of decoration with mix.env == :prod

  defmodule User do
    use ElixirLogflow, mix_envs: [:prod]
    decorate_fn_with: LogDecorator

    def say(word) do
      wor
    end
  end

  # todo: result of decoration with mix.env == :prod

  """

  require FnDef

  @default_mix_envs [:dev]
  @decorators []

  """
  Inteface
  """

  defmacro __using__(args_ast) do
    do_using(args_ast)
  end

  @doc """
  The decorator mechanism.
  Override the original Kernel.def by not inlucing it in
  the import statement.
  """
  defmacro def(fn_call_ast, fn_options_ast) do
    do_def(fn_call_ast, fn_options_ast)
  end

  defmacro decorate_fn_with(decorator) do
    @decorators = List.insert_at(@decorators, -1, decorator)
  end

  """
  Utility functions
  """

  def do_using(args_ast, current_env \\ Mix.env) do
    {mix_envs} = calc_args(args_ast)

    case Enum.find_value(mix_envs, false, fn env -> current_env == env end) do
      true ->
        generate_using_ast
      false ->
        nil
    end
  end

  def generate_using_ast do
    quote do
      import Kernel, except: [def: 2]
      import ElixirLogflow, only: [def: 2, decorate_fn_with: 1]
      @decorators = []
    end
  end

  def calc_args(args_ast) do
    {args, []} = Code.eval_quoted(args_ast)

    args = case args do
      nil -> []
      _ -> args
    end

    mix_envs = Keyword.get(args, :mix_envs,
      @default_mix_envs)

    {mix_envs}
  end

  def do_def(fn_call_ast, fn_options_ast) do
    {
      :ok,
      %FnDef{
        fn_call_ast: result_fn_call_ast,
        fn_options_ast: result_fn_options_ast
      }
    } =
    decorate_function_def(
      %FnDef{fn_call_ast: fn_call_ast,
        fn_options_ast: fn_options_ast,
      },
      @decorators)

    quote do
      Kernel.def unquote(result_fn_call_ast), unquote(result_fn_options_ast)
    end
  end

  @doc """
  Function decorator implementor.
  """
  @todo "receive decorators as list and implement in loop"

  def decorate_function_def(%FnDef{} = fn_def, []) do
    {:ok, fn_def}
  end

  def decorate_function_def(%FnDef{} = fn_def, [decorator | rest_decorators]) do
    {:ok, _result_fn_def} =
    fn_def
    |> decorator.decorate(rest_decorators)
  end
end
