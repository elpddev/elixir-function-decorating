defmodule ElixirLogflowTest do
  use ExUnit.Case
  doctest ElixirLogflow

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "do_def" do
    call_ast = quote(unquote: false) do say_hello end
    body_ast = quote(unquote: false) do [do: :ok] end
    expected_ast =
    {{:., [], [{:__aliases__, [alias: false], [:Kernel]}, :def]}, [],
            [{:say_hello, [], ElixirLogflowTest},
             [do: {:__block__, [],
               [{{:., [], [{:__aliases__, [alias: false], [:IO]}, :puts]}, [],
                 [{:<<>>, [],
                   ["Calling ",
                    {:::, [],
                     [{{:., [], [Kernel, :to_string]}, [],
                       [{:inspect, [context: ElixirLogflow, import: Kernel],
                         [{:{}, [], [:say_hello, [], ElixirLogflowTest]}]}]},
                      {:binary, [], ElixirLogflow}]}]}]}, :ok]}]]}

    result_ast = ElixirLogflow.do_def(call_ast, body_ast)
    assert ^expected_ast = result_ast
  end
end
