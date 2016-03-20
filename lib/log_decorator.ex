defmodule LogDecorator do
  require FnDef
  # todo: add use FunctionDecorator behaviour

  def decorate(
    %FnDef{fn_call_ast: fn_call_ast, fn_options_ast: fn_options_ast} = fn_def) do

    {fn_name_ast, fn_args_ast} = FnDef.parse_fn_name_and_args(fn_call_ast)
    {arg_names, decorated_args} = FnDef.decorate_args(fn_args_ast)
    decorated_fn_call_ast = replace_args_with_decorated_args(fn_call_ast,
      fn_name_ast, fn_args_ast, decorated_args)

    decorated_fn_options_ast = Keyword.update(fn_options_ast, :do, nil,
      fn do_opt ->
        quote do
          result = unquote(do_opt)
          LogDecorator.log_post(__ENV__, unquote(fn_name_ast),
            unquote(arg_names), result)
          result
        end
      end
    )

    %FnDef{ fn_def |
      fn_call_ast: decorated_fn_call_ast,
      fn_options_ast: decorated_fn_options_ast
    }
  end

  def log_post(env, fun_name, args_names, result) do
    IO.puts generate_log_post_line(env, fun_name, args_names, result)
  end

  def generate_log_post_line(%{module: module} = _, fun_name, args_names, result) do
    "#{inspect(self)} [x] #{module}.#{fun_name}" <>
      "(#{inspect(args_names)})" <>
      " -> #{inspect(result)}"
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
