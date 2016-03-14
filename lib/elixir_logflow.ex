defmodule ElixirLogflow do
  defmacro __using__(args_ast) do
    do_using(args_ast)
  end

  defmacro def(fun_def_ast, opts_ast) do
    do_def(fun_def_ast, opts_ast)
  end

  def do_def(fun_def_ast, opts_ast) do
    quote do
      Kernel.def unquote(fun_def_ast) do
        do_log(unquote(Macro.escape(fun_def_ast)))
        unquote((opts_ast[:do]))
      end
    end
  end

  def do_log(fun_def_ast_struct) do
    IO.puts "Calling #{inspect fun_def_ast_struct}"
  end

  def do_using(args_ast) do
    {args, []} = Code.eval_quoted(args_ast)
    skip_log_flag = Keyword.get(args, :skip_log, false)

    case skip_log_flag do
      true ->
        nil
      false ->
        quote do
          import Kernel, except: [def: 2]
          import ElixirLogflow, only: [def: 2]
        end
    end
  end
end
