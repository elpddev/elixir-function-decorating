defmodule FnDef do
  @moduledoc """

  """

  defstruct [
    fn_call_ast: nil,
    fn_options_ast: nil
  ]

  @doc """
  Parse a function call into its parts: name and arguments
  """
  def parse_fn_name_and_args({:when, _, [short_head | _]}),
    do: parse_fn_name_and_args(short_head)

  def parse_fn_name_and_args(short_head),
    do: Macro.decompose_call(short_head)

  @doc """
  Add meidator arguments to a function arguments list ast.

  Mainly for the availabity to print unbounded arguments
  in a function call.

  say(word) -> say(word = arg0)

  Returns {[args names], [decorated args ast]}
  ## Examples

  ```elixir
    iex> FnDef.decorate_args(quote context: __MODULE__ do [a, b, _] end)
    {[{:arg0, [], FnDef}, {:arg1, [], FnDef}, {:arg2, [], FnDef}],
      [{:=, [], [{:a, [], __MODULE__}, {:arg0, [], FnDef}]},
        {:=, [], [{:b, [], __MODULE__}, {:arg1, [], FnDef}]},
        {:=, [], [{:_, [], __MODULE__}, {:arg2, [], FnDef}]}]}

  ```
  """
  @spec decorate_args(list) :: {list, list}
  def decorate_args([]), do: {[],[]}
  def decorate_args(args_ast) do
   Enum.with_index(args_ast)
     |> Enum.map(&decorate_arg/1)
     |> Enum.unzip
  end

  @doc """
  Add mediator argument to a function argument ast.

  Returns {decorated argument name, decorated argument ast}

  ## Examples
  ```elixir
    iex> FnDef.decorate_arg({quote context: __MODULE__ do first_name end, 0})
    {{:arg0, [], FnDef}, {:=, [], [{:first_name, [], __MODULE__}, {:arg0, [], FnDef}]}}

  ```
  """
  @spec decorate_arg({Macro.t, non_neg_integer}) :: {Macro.t, Macro.t}
  def decorate_arg({arg_ast, index}) do
    mediator_arg_ast = Macro.var(:"arg#{index}", __MODULE__)
    full_arg = calc_full_arg(arg_ast, mediator_arg_ast)
    {mediator_arg_ast, full_arg}
  end

  @doc """
  Generate AST for argument AST and its mediator.

  ## Examples
  ```elixir
    iex> FnDef.calc_full_arg(quote context: __MODULE__ do first_name end, quote context: __MODULE__ do arg0 end)
    {:=, [], [{:first_name, [], __MODULE__}, {:arg0, [], __MODULE__}]}

  ```
  """
  @spec calc_full_arg(Macro.t, Macro.t) :: Macro.t
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
