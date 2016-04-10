defmodule LogDecoratorTest do
  use ExUnit.Case

  doctest LogDecorator

  test "decorate - with simple params" do
    {:ok, %FnDef{
      fn_call_ast: result_fn_call_ast,
      fn_options_ast: result_fn_options_ast
    }} =
    LogDecorator.decorate(%FnDef{
        fn_call_ast: quote do beep(word) end,
        fn_options_ast: quote do [do: word] end
      }
    )

    mediator_var_ast = Macro.var(:arg0, FnDef)
    assert result_fn_call_ast == (quote do
      beep(word = unquote(mediator_var_ast))
    end)

    result_var_ast = quote context: LogDecorator do result end

    assert result_fn_options_ast == [do: (quote do
      LogDecorator.log_pre(
        unquote(quote context: LogDecorator do __ENV__ end),
        :beep,
        [unquote(quote context: FnDef do :word end)],
        [unquote(quote context: FnDef do arg0 end)],
        [])

      unquote(result_var_ast) = word

      LogDecorator.log_post(
        unquote(quote context: LogDecorator do __ENV__ end),
        :beep,
        [unquote(quote context: FnDef do :word end)],
        [unquote(quote context: FnDef do arg0 end)],
        unquote(result_var_ast), 
        [])
      unquote(result_var_ast)
    end)]
  end

  test "generate_log_pre_line" do
    current_timestamp = {{2016, 4, 7}, {5, 58, 4}}
    expected_format_timestamp = LogDecorator.format_timestamp(current_timestamp)
    result = LogDecorator.generate_log_pre_line(%{module: MyModule},
      "beep", [:first_name], ["arg0"], [], current_timestamp)

    assert result == "#{expected_format_timestamp}, #{inspect(self)} [ ] Elixir.MyModule.beep\n- first_name: \"arg0\""
  end

  test "generate_log_post_line" do
    current_timestamp = {{2016, 4, 7}, {5, 58, 4}}
    expected_format_timestamp = LogDecorator.format_timestamp(current_timestamp)
    result = LogDecorator.generate_log_post_line(%{module: MyModule},
      "beep", [:word], ["arg0"], "hello", [], current_timestamp)

    assert result == "#{expected_format_timestamp}, #{inspect(self)} [x] Elixir.MyModule.beep\n- word: \"arg0\" -> \"hello\""
  end
  
  """ 
  todo: check inspect width option
  test "generate_log_post_line - with output options" do
    result = LogDecorator.generate_log_post_line(%{module: MyModule}, "beep", ["arg0"], "hello_there_world", inspect_width: 2)

    assert result == "#{inspect(self)} [x] Elixir.MyModule.beep([\"arg0\"]) -> \"hello\""
  end
  """

  test "replace_args_with_decorated_args" do
    fn_call_ast = quote do beep(word) end
    {fn_name_ast, fn_args_ast} = FnDef.parse_fn_name_and_args(fn_call_ast)
    {_args_calc_names, _arg_names, decorated_args} = FnDef.decorate_args(fn_args_ast)

    result = LogDecorator.replace_args_with_decorated_args(
      fn_call_ast, fn_name_ast, fn_args_ast, decorated_args)

    arg0_ast = quote context: FnDef do arg0 end
    assert result == (quote do beep(word = unquote(arg0_ast)) end)
  end

  test "get_system_time" do
    assert LogDecorator.get_system_time({1460, 8684, 727856}) == 
      {{2016, 4, 7}, {5, 58, 4}}
  end

  test "format_timestamp" do
    assert LogDecorator.format_timestamp({{2016, 4, 7}, {5, 58, 4}}
) == 
      "2016-4-7, 5:58.4"
  end

  test "generate_args_lines" do
    assert LogDecorator.generate_args_lines(
        ["arg_val_1", "arg_val_2"], [:arg1, :arg2], 100, 100, 80) == 
      "- arg1: \"arg_val_1\"\n- arg2: \"arg_val_2\"" 
  end

  test "generate_args_lines" do
  end

  test "generate_arg_line" do
    assert LogDecorator.generate_arg_line(:number, "123456789", 100, 100, 5) ==
      "- number: \"1234\"\n"
  end
end
