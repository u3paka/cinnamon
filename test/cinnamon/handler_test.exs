defmodule Cinnamon.HandlerTest do
  use ExUnit.Case
  doctest Cinnamon.Handler

  test "cmd pattern-match of message" do
    assert Cinnamon.Handler.message("(hoge fuga)", %{}, %{}) == "hoge"
  end

end
