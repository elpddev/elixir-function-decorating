defmodule FunctionDecoratingTest do
  use ExUnit.Case
  doctest FunctionDecorating

  test "calc args - mix_envs - default" do
    assert FunctionDecorating.calc_args(quote do nil end) == {[:dev], :test}
  end

  test "do_using - simple - mix env = dev" do
    result_ast = FunctionDecorating.do_using(quote do [current_mix_env: :dev] end)
    assert result_ast == FunctionDecorating.generate_using_ast
  end

  test "do_using - simple - mix env = prod" do
    result_ast = FunctionDecorating.do_using(quote do [current_mix_env: :prod] end)
    expected_ast = FunctionDecorating.generate_bare_using_ast
    assert result_ast == expected_ast
  end

  test "do_using - with 'mix_envs: [:prod]', mix env = :prod" do
    result_ast = FunctionDecorating.do_using(quote do [mix_envs: [:prod], current_mix_env: :prod] end)
    assert result_ast == FunctionDecorating.generate_using_ast
  end

  test "decorate_function_def" do
    fn_call_ast = quote do beep(word) end
    fn_options_ast = [do: quote do word end]

    defmodule TestModuleDecorator do
      def decorate(
        %FnDef{
          fn_call_ast: in_fn_call_ast,
          fn_options_ast: [do: in_do_block] = _in_fn_options_ast
          } = _fn_def) do

        {:ok, %FnDef{
          fn_call_ast: in_fn_call_ast,
          fn_options_ast: [do: quote do
            decorate_1
            unquote(in_do_block)
          end]
          }}
      end
    end

    result = FunctionDecorating.decorate_function_def(%FnDef{
        fn_call_ast: fn_call_ast, fn_options_ast: fn_options_ast},
        [TestModuleDecorator])

    decorating_exp = quote context: TestModuleDecorator do decorate_1 end

    assert result == {:ok, %FnDef{
        fn_call_ast: quote do beep(word) end,
        fn_options_ast: [do: quote do
          unquote(decorating_exp)
          word
        end]
      }}
  end
end
