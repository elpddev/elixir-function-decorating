defmodule FunctionDecorator do
  @callback decorate(%FnDef{}) :: {:ok, %FnDef{}}
end
