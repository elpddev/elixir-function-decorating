defmodule ElixirLogflow do
  require FnDef
  require LogDecorator

  defmacro __using__(args_ast) do
    do_using(args_ast)
  end

  """
  Inteface
  """

  @doc """
  The decorator mechanism.
  Override the original Kernel.def by not inlucing it in
  the import statement.
  """
  defmacro def(fn_call_ast, fn_options_ast) do
    decorate_function_def(fn_call_ast, fn_options_ast)
  end

  """
  Utility functions
  """

  @doc """
  Function decorator implementor.
  """
  @todo "receive decorators as list and implement in loop"
  def decorate_function_def(fn_call_ast, fn_options_ast) do
    %FnDef{
      fn_call_ast: result_fn_call_ast,
      fn_options_ast: result_fn_options_ast
    } =
    %FnDef{fn_call_ast: fn_call_ast, fn_options_ast: fn_options_ast}
    |> LogDecorator.decorate

    quote do
      Kernel.def unquote(result_fn_call_ast), unquote(result_fn_options_ast)
    end
  end

  def do_using(args_ast) do
    {args, []} = Code.eval_quoted(args_ast)
    skip_log_flag = Keyword.get(args, :skip_log,
      decide_default_skip_log_per_env)

    case skip_log_flag do
      true ->
        nil
      false ->
        quote do
          import Kernel, except: [def: 2]
          import ElixirLogflow, only: [def: 2, do_log_post: 4]
        end
    end
  end

  def decide_default_skip_log_per_env(mix_env \\ Mix.env) do
    if mix_env == :dev, do: false, else: true
  end
end
