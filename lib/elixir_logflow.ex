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

  # ******************
  # Utility functions
  # ******************

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
      Module.register_attribute(__MODULE__, :decorators, accumulate: true)
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
    quote bind_quoted: [
        orig_fn_call_ast: Macro.escape(fn_call_ast),
        orig_fn_options_ast: Macro.escape(fn_options_ast)
      ] do

      decorators = Module.get_attribute(__MODULE__, :decorators)

      {
        :ok,
        %FnDef{
          fn_call_ast: result_fn_call_ast,
          fn_options_ast: result_fn_options_ast
        }
      } =
      ElixirLogflow.decorate_function_def(
        %FnDef{fn_call_ast: orig_fn_call_ast,
          fn_options_ast: orig_fn_options_ast,
        },
        decorators)

      exp = quote do
        Kernel.def(unquote(result_fn_call_ast), unquote(result_fn_options_ast))
      end
      Code.eval_quoted(exp, [], __ENV__)
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
    {:ok, result_fn_def} =
    fn_def
    |> decorator.decorate

    decorate_function_def(result_fn_def, rest_decorators)
  end

  # ******************
  # Inteface
  # ******************

  defmacro __using__(args_ast) do
    do_using(args_ast)
  end

  defmacro decorate_fn_with(decorator_ast) do
    quote do
      @decorators unquote(decorator_ast)
    end
  end

  @doc """
  The decorator mechanism.
  Override the original Kernel.def by not inlucing it in
  the import statement.
  """
  defmacro def(fn_call_ast, fn_options_ast) do
    ElixirLogflow.do_def(fn_call_ast, fn_options_ast)
  end
end
