defmodule LogDecorator do
  @behaviour FunctionDecorator

  @todo :test 
  def decorate(
    %FnDef{fn_call_ast: fn_call_ast, 
       fn_options_ast: fn_options_ast} = fn_def, 
       decorate_options_ast \\ Macro.escape([])) do

    {fn_name_ast, fn_args_ast} = FnDef.parse_fn_name_and_args(fn_call_ast)
    {arg_names, decorated_args} = FnDef.decorate_args(fn_args_ast)
    decorated_fn_call_ast = replace_args_with_decorated_args(fn_call_ast,
      fn_name_ast, fn_args_ast, decorated_args)

    decorated_fn_options_ast = Keyword.update(fn_options_ast, :do, nil,
      fn do_opt ->
        quote do
          LogDecorator.log_pre(__ENV__, unquote(fn_name_ast),
            unquote(arg_names), unquote(decorate_options_ast))
          result = unquote(do_opt)
          LogDecorator.log_post(__ENV__, unquote(fn_name_ast),
            unquote(arg_names), result, unquote(decorate_options_ast))
          result
        end
      end
    )

    {:ok, %FnDef{ fn_def |
      fn_call_ast: decorated_fn_call_ast,
      fn_options_ast: decorated_fn_options_ast
    }}
  end

  def log_pre(env, fun_name, args_names, output_args) do
    IO.puts generate_log_pre_line(env, fun_name, args_names, output_args)
  end

  def log_post(env, fun_name, args_names, result, output_args) do
    log_post? = Keyword.get(output_args, :log_post?, false)

    if log_post?, do: IO.puts generate_log_post_line(
      env, fun_name, args_names, result, output_args)
  end

  def generate_log_pre_line(
    %{module: module} = _, fun_name, args_names, result, output_args \\ [],
    current_timestamp \\ get_system_time) do

    {inspect_limit, inspect_width} = calc_output_args(output_args)

    "#{format_timestamp(current_timestamp)}, #{inspect(self)}" <> 
    " [ ] #{module}.#{fun_name}" <>
    "#{inspect(args_names, limit: inspect_limit, width: inspect_width)}" 
  end

  def generate_log_post_line(
    %{module: module} = _, fun_name, args_names, result, output_args \\ [], 
    current_timestamp \\ get_system_time) do

    {inspect_limit, inspect_width} = calc_output_args(output_args)

    "#{format_timestamp(current_timestamp)}, " <>
    "#{inspect(self)} [x] #{module}.#{fun_name}" <>
    "(#{inspect(args_names, limit: inspect_limit, width: inspect_width)})" <>
    " -> #{inspect(result, limit: inspect_limit, width: inspect_width)}"
  end

  def get_system_time(current_timestamp \\ :os.timestamp) do
    current_timestamp |> :calendar.now_to_datetime
  end

  def format_timestamp(
    {{year, month, day}, {hours, minutes, seconds}} = _timestamp) do

    "#{year}-#{month}-#{day}, #{hours}:#{minutes}.#{seconds}" 
  end

  def calc_output_args(args) do
    inspect_limit = Keyword.get(args, :inspect_limit, 15)
    inspect_width = Keyword.get(args, :inspect_width, 50)

    {inspect_limit, inspect_width}
  end

  def replace_args_with_decorated_args(head, fun_name, args_ast, decorated_args) do
   Macro.postwalk(head, fn(node) ->
     case node do
       {fun_ast, context, old_args} when (fun_ast == fun_name and old_args == args_ast) ->
         {fun_ast, context, decorated_args}
       other -> other
     end
   end)
 end
end
