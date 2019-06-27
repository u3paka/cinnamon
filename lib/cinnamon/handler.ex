defmodule Cinnamon.Handler do

  use Slack

  def message(text, channel, slack) do
    do_message(text)
  end

  @doc"""

  # Exapmles

  iex> do_message("hoge", "hoge")
  """
  defp do_message(text) do
    Mantra.Morpho.parse(text)
    |> IO.inspect
  end
end
