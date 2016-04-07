defmodule FunctionDecorating do
  @moduledoc """
  Add a function decorating availability to a module.

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

  iex >User.say("hello")
  #PID<0.86.0> [x] Elixir.User.say(["hello"]) -> "hello"
  "hello"
  ```

  Default usage is for Mix.env == :dev only. To override it:

  ```elixir
  defmodule User do
    use FunctionDecorating mix_envs: [:prod]
    decorate_fn_with(LogDecorator)

    def say(word) do
      word
    end
  end

  iex >Mix.env
  :prod

  iex >User.say("hello")
  #PID<0.86.0> [x] Elixir.User.say(["hello"]) -> "hello"
  "hello"
  ```
  """

  @default_mix_envs [:dev]

  # ******************
  # Utility functions
  # ******************

  def do_using(args_ast) do
    {mix_envs, current_mix_env} = calc_args(args_ast)

    case Enum.find_value(mix_envs, false, fn env -> current_mix_env == env end) do
      true ->
        generate_using_ast
      false ->
        generate_bare_using_ast
    end
  end

  def generate_using_ast do
    quote do
      import Kernel, except: [def: 2]
      import FunctionDecorating, only: [def: 2, decorate_fn_with: 1, decorate_fn_with: 2]
      Module.register_attribute(__MODULE__, :decorators, accumulate: true)
    end
  end

  def generate_bare_using_ast do
    quote do
      import FunctionDecorating, only: [decorate_fn_with: 1, decorate_fn_with: 2]
      Module.register_attribute(__MODULE__, :decorators, accumulate: true)
    end
  end

  def calc_args(args_ast, current_env \\ Mix.env ) do
    {args, []} = Code.eval_quoted(args_ast)

    args = case args do
      nil -> []
      _ -> args
    end

    calc_curr_mix_env = Keyword.get(args, :current_mix_env, current_env)
    
    mix_envs = Keyword.get(args, :mix_envs,
      @default_mix_envs)

    {mix_envs, calc_curr_mix_env}
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
      FunctionDecorating.decorate_function_def(
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

  def decorate_function_def(%FnDef{} = fn_def, []) do
    {:ok, fn_def}
  end

  def decorate_function_def(%FnDef{} = fn_def, [{decorator, decorator_options} = decorator_def | rest_decorators]) do
    {:ok, result_fn_def} =
    fn_def
    |> decorator.decorate decorator_options

    decorate_function_def(result_fn_def, rest_decorators)
  end

  # ******************
  # Inteface
  # ******************

  defmacro __using__(args_ast) do
    do_using(args_ast)
  end

  defmacro decorate_fn_with(decorator_ast, options_ast \\ Macro.escape([])) do
    quote do
      @decorators {unquote(decorator_ast), unquote(options_ast)}
    end
  end

  @doc """
  The decorator mechanism.
  Override the original Kernel.def by not inlucing it in
  the import statement.
  """
  defmacro def(fn_call_ast, fn_options_ast) do
    FunctionDecorating.do_def(fn_call_ast, fn_options_ast)
  end
end
