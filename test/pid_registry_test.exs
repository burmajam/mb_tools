defmodule MbTools.PidRegistryTest do
  use ExUnit.Case, async: true

  alias MbTools.PidRegistry, as: Registry

  setup do
    {:ok, registry} = Registry.start_link
    {:ok, registry: registry}
  end

  test "associates pid to key", %{registry: registry} do
    key = "something"
    {:ok, pid} = Agent.start_link(fn -> %{} end)

    assert Registry.get(registry, key) == :error
    :ok = Registry.register(registry, key, pid)
    assert {:ok, ^pid} = Registry.get(registry, key)
  end

  test "removes pid when it crashes", %{registry: registry} do
    key = "something"
    {:ok, pid} = Agent.start_link(fn -> %{} end)

    Registry.register(registry, key, pid)
    assert {:ok, ^pid} = Registry.get(registry, key)
    Agent.stop pid
    assert Registry.get(registry, key) == :error
  end
end
