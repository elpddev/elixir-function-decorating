defmodule User do
  use FunctionDecorating
  decorate_fn_with(LogDecorator)
  
  def say(word) do
    word
  end
end
