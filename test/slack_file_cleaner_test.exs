defmodule SlackFileCleanerTest do
  use ExUnit.Case
  doctest SlackFileCleaner

  test "greets the world" do
    assert SlackFileCleaner.hello() == :world
  end
end
