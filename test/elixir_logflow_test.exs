defmodule ElixirLogflowTest do
  use ExUnit.Case
  doctest ElixirLogflow

  test "do_def" do
    call_ast = quote(unquote: false) do say_hello end
    body_ast = quote(unquote: false) do [do: :ok] end
    fun_name = ""
    expected_ast = quote context: ElixirLogflow do
      Kernel.def unquote({:say_hello, [], ElixirLogflowTest}) do
        module = __ENV__.module
        function_name = unquote(fun_name)

        ElixirLogflow.do_log_pre(module,
          unquote({:{}, [], [:say_hello, [], ElixirLogflowTest]}))
        result = :ok
        ElixirLogflow.do_log_pst(module,
          unquote({:{}, [], [:say_hello, [], ElixirLogflowTest]}),
          result)

        result
      end
    end

    result_ast = ElixirLogflow.do_def(call_ast, body_ast)
    assert ^expected_ast = result_ast
  end

  test "do_using with override" do
    result_ast = ElixirLogflow.do_using(quote do [skip_log: true] end)
    assert nil == result_ast
  end

  test "do_using without override" do
    expected_ast = quote context: ElixirLogflow do
      import Kernel, except: [def: 2]
      import ElixirLogflow, only: [def: 2]
    end
    result_ast = ElixirLogflow.do_using(quote do [skip_log: false] end)
    assert ^expected_ast = result_ast
  end


  test "decide_default_skip_log_per_env" do
    assert ElixirLogflow.decide_default_skip_log_per_env(:dev) == false
    assert ElixirLogflow.decide_default_skip_log_per_env(:test) == true
    assert ElixirLogflow.decide_default_skip_log_per_env(:prod) == true
  end
end
