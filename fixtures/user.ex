defmodule User do
  use FunctionDecorating
  decorate_fn_with(LogDecorator)
  
  def say(word) do
    word
  end

  def say_map(%{word: word}) do
    word
  end

  def say_tuple({word}) do
    word
  end

  def say_array([word]) do
    word
  end
end
