defmodule FnDefTest do
  use ExUnit.Case
  doctest FnDef

  test "parse_fn_name_and_args - simple case" do
    result = FnDef.parse_fn_name_and_args(quote(do: beep))
    assert {:beep, []} == result
  end

  test "parse_fn_name_and_args - with params" do
    result = FnDef.parse_fn_name_and_args(quote(do: beep("hi")))
    assert {:beep, ["hi"]} == result
  end

  test "parse_fn_name_and_args - 'when' clause" do
    result = FnDef.parse_fn_name_and_args(quote do
        beep(word) when word == "hi"
      end
    )

    assert {:beep, [{:word, _, _}]} = result
  end

  test "decorate_args - empty" do
    # todo
  end

  test "decorate_args - complex" do
    # todo
  end

  test "decorate_arg - simple variable" do
    var_exp = quote do first_name end
    expected_result = quote context: FnDef do
      unquote(var_exp) = arg2
    end

    {result_arg_name, result_full_arg} =
      FnDef.decorate_arg({quote(do: first_name), 2})

    assert result_arg_name == (quote context: FnDef do arg2 end)
    assert result_full_arg == expected_result
  end

  test "decorate_arg - unbound variable" do
    var_exp = quote do _ end
    expected_result = quote context: FnDef do
      unquote(var_exp) = arg3
    end

    {result_arg_name, result_full_arg} =
      FnDef.decorate_arg({quote(do: _), 3})

    assert result_arg_name == (quote context: FnDef do arg3 end)
    assert result_full_arg == expected_result
  end

  test "decorate_arg - variable with default" do
    mediator_var_exp = quote context: FnDef do arg0 end
    expected_result = quote do
      first_name = unquote(mediator_var_exp) \\ "john"
    end

    {result_arg_name, result_full_arg} =
      FnDef.decorate_arg({quote(do: first_name \\ "john"), 0})

    assert result_arg_name == (quote context: FnDef do arg0 end)
    assert result_full_arg == expected_result
  end
end
