defmodule Cinnamon.BotWorker do
  use Slack

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      shutdown: 5_000,
      restart: :permanent,
      type: :worker
    }
  end

  def start_link(initial_state) do
    IO.puts Application.get_env(:cinnamon, :slack_token)
    Slack.Bot.start_link(__MODULE__, initial_state, Application.get_env(:cinnamon, :slack_token))
  end

  def handle_connect(slack, state) do
    IO.puts "Connected as #{slack.me.id}"
    Agent.start_link(fn -> slack.me.id end, name: UserInfo)
    {:ok, state}
  end

  def handle_event(message = %{channel: channel, type: "message", text: text}, slack, state) do
    Cinnamon.Handler.message(text, channel, slack)
    {:ok, state}
  end

  def handle_event(message = %{channel: channel, type: "user_typing", user: user}, slack, state) do
    IO.puts "#{user} is typing...at #{channel}"
    {:ok, state}
  end

  def handle_event(message = %{type: "file_shared", file_id: file_id, channel_id: channel, ts: _ts}, slack, state) do
    IO.inspect message
    case Slack.Web.Files.info(file_id) do
      %{"file" => %{"url_private_download" => url, "user" => user, "name" => name}} = result ->
        headers = ["Authorization": "Bearer #{Application.get_env(:cinnamon, :slack_token)}"]
        %HTTPoison.Response{body: body} = HTTPoison.get!(url, headers)

        path = "./tmp/#{user}/#{name}"
        path
        |> Path.dirname
        |> File.mkdir_p
        |> case do
             :ok ->
               File.write!(path, body)
             error -> error
           end
           |> IO.inspect

        if File.exists?(path) do
        "lpr"
        |> System.find_executable()
        |> case do
             nil ->
               send_message("lprに非対応のサーバーです。管理者に問い合わせてください。", channel, slack)
             cmd ->
               {result, 0} = System.cmd(cmd, [path])
               send_message("Printing... #{result}", channel, slack)
           end
        end
        {:ok, state}

      result ->
        IO.inspect result
        {:ok, state}
     end
  end

  def handle_event(message = %{type: type}, slack, state) do
    IO.inspect message
    {:ok, state}
  end

  def handle_info(_, _, state), do: {:ok, state}
end
