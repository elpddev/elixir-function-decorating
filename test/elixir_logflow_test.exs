defmodule ElixirLogflowTest do
  use ExUnit.Case
  doctest ElixirLogflow

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "do_def" do
    call_ast = quote(unquote: false) do say_hello end
    body_ast = quote(unquote: false) do [do: :ok] end
    expected_ast = quote context: ElixirLogflow do
      Kernel.def unquote({:say_hello, [], ElixirLogflowTest}) do
        do_log(unquote({:{}, [], [:say_hello, [], ElixirLogflowTest]}))
        :ok
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


  test "env override" do
    call_ast = quote(unquote: false) do say_hello end
    body_ast = quote(unquote: false) do [do: :ok] end
  end
end
