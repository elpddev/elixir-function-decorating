defmodule ElixirLogflow do
  require FnDef

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
    |> decorate_with_log

    quote do
      Kernel.def unquote(result_fn_call_ast), unquote(result_fn_options_ast)
    end
  end

  def decorate_with_log(
    %FnDef{fn_call_ast: fn_call_ast, fn_options_ast: fn_options_ast} = fn_def) do

    {fn_name_ast, fn_args_ast} = FnDef.parse_fn_name_and_args(fn_call_ast)
    {arg_names, decorated_args} = FnDef.decorate_args(fn_args_ast)
    decorated_fn_call_ast = replace_args_with_decorated_args(fn_call_ast,
      fn_name_ast, fn_args_ast, decorated_args)

    decorated_fn_options_ast = Keyword.update(fn_options_ast, :do, nil,
      fn do_opt ->
        quote do
          module = __ENV__.module
          result = unquote(do_opt)
          do_log_post(module, unquote(fn_name_ast),
            unquote(arg_names), result)
          result
        end
      end
    )

    %FnDef{ fn_def |
      fn_call_ast: decorated_fn_call_ast,
      fn_options_ast: decorated_fn_options_ast
    }
  end

  def do_log_post(module, fun_name, args_names, result) do
    IO.puts "#{inspect(self)} [x] #{module}.#{fun_name}" <>
      "(#{inspect(args_names)})" <>
      " : #{inspect(result)}"
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

  defp replace_args_with_decorated_args(head, fun_name, args_ast, decorated_args) do
   Macro.postwalk(head, fn(node) ->
     case node do
       {fun_ast, context, old_args} when (fun_ast == fun_name and old_args == args_ast) ->
         {fun_ast, context, decorated_args}
       other -> other
     end
   end)
 end

 defp parse_fn_name_and_args({:when, _, [short_head | _]}),
   do: parse_fn_name_and_args(short_head)

 defp parse_fn_name_and_args(short_head),
   do: Macro.decompose_call(short_head)

 defp decorate_args([]), do: {[],[]}
 defp decorate_args(args_ast) do
   Enum.with_index(args_ast)
     |> Enum.map(&decorate_arg/1)
     |> Enum.unzip
 end

 defp decorate_arg({arg_ast, index}) do
   if elem(arg_ast, 0) == :\\  do
     {:\\, _, [{optional_name, _, _}, _]} = arg_ast
     { Macro.var(optional_name, nil), arg_ast}
   else
     arg_name = Macro.var(:"arg#{index}", __MODULE__)

     full_arg = quote do
       unquote(arg_ast) = unquote(arg_name)
     end

     {arg_name, full_arg}
   end
 end
end
