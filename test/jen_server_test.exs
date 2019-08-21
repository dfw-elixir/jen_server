defmodule JenServerTest do
  use ExUnit.Case
  doctest JenServer

  test "greets the world" do
    assert JenServer.hello() == :world
  end
end
