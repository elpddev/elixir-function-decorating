defmodule ElixirLogflow do
  defmacro __using__(_) do
    quote do
      import Kernel, except: [def: 2]
      import ElixirLogflow
    end
  end

  defmacro def(fun_def_ast, opts_ast) do
    do_def(fun_def_ast, opts_ast)
  end

  def do_def(fun_def_ast, opts_ast) do
    quote do
      Kernel.def unquote(fun_def_ast) do
        IO.puts "Calling #{inspect unquote(Macro.escape(fun_def_ast))}"
        unquote((opts_ast[:do]))
      end
    end
  end
end
