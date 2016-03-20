defmodule FnDef do
  defstruct [
    fn_call_ast: nil,
    fn_options_ast: nil
  ]

  def parse_fn_name_and_args({:when, _, [short_head | _]}),
    do: parse_fn_name_and_args(short_head)

  def parse_fn_name_and_args(short_head),
    do: Macro.decompose_call(short_head)

  def decorate_args([]), do: {[],[]}
  def decorate_args(args_ast) do
   Enum.with_index(args_ast)
     |> Enum.map(&decorate_arg/1)
     |> Enum.unzip
  end

  def decorate_arg({arg_ast, index}) do
    mediator_arg_ast = Macro.var(:"arg#{index}", __MODULE__)
    full_arg = calc_full_arg(arg_ast, mediator_arg_ast)
    {mediator_arg_ast, full_arg}
  end

  def calc_full_arg(arg_ast, mediator_arg_ast) when elem(arg_ast, 0) == :\\ do
    {:\\, _, [{_, _, _} = full_optional_name, default_arg_value]} = arg_ast
    quote do
      unquote(full_optional_name) = unquote(mediator_arg_ast) \\ unquote(default_arg_value)
    end
  end

  def calc_full_arg(arg_ast, mediator_arg_ast) do
    quote do
      unquote(arg_ast) = unquote(mediator_arg_ast)
    end
  end
end
