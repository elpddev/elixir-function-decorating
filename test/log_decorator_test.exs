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
      unquote(result_var_ast) = word
      LogDecorator.log_post(
        unquote(quote context: LogDecorator do __ENV__ end),
        :beep,
        [unquote(quote context: FnDef do arg0 end)],
        unquote(result_var_ast), 
        [])
      unquote(result_var_ast)
    end)]
  end

  test "generate_log_post_line" do
    result = LogDecorator.generate_log_post_line(%{module: MyModule},
      "beep", ["arg0"], "hello")

    assert result == "#{inspect(self)} [x] Elixir.MyModule.beep([\"arg0\"]) -> \"hello\""
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
    {_arg_names, decorated_args} = FnDef.decorate_args(fn_args_ast)

    result = LogDecorator.replace_args_with_decorated_args(
      fn_call_ast, fn_name_ast, fn_args_ast, decorated_args)

    arg0_ast = quote context: FnDef do arg0 end
    assert result == (quote do beep(word = unquote(arg0_ast)) end)
  end
end
