defmodule FunctionDecoratingIntegrationTest do
  use ExUnit.Case

  test "compile for prod with decorator usage" do
    module = defmodule TestModule do
      use FunctionDecorating, mix_envs: [:dev], current_mix_env: :prod
      decorate_fn_with LogDecorator
    end

    assert module != nil
  end
end
 
