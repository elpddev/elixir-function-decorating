defmodule FnDefDecorator do
  @callback decorate(%FnDef{}) :: {:ok, %FnDef{}}
end
