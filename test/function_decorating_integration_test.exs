defmodule FunctionDecoratingIntegrationTest do
  use ExUnit.Case

  test "compile for prod with decorator usage" do
    module = defmodule TestModule do
      use FunctionDecorating, mix_envs: [:dev], current_mix_env: :prod
      decorate_fn_with LogDecorator
    end

    assert module != nil
  end

  test "" do
    module = defmodule TestModule do
      use FunctionDecorating, mix_envs: [:dev], current_mix_env: :dev 
      decorate_fn_with LogDecorator, inspect_limit: 5

      def test_a do
        for n <- 1..10, into: "", do: "a"
      end

      def test_b(first_var) do
        first_var
      end
    end

    TestModule.test_a
  end
end
 
