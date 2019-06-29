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
    Agent.start_link(fn -> Slack.Web.Channels.list()["channels"] end, name: ChannelList)
    {:ok, state}
  end

  def handle_event(message = %{channel: channel, type: "channel_joined"}, slack, state) do
   Agent.update(ChannelList, fn state -> [channel | state] end)
    {:ok, state}
  end

  def handle_event(message = %{channel: channel, user: user, type: "member_joined_channel", text: text}, slack, state) do
    username = Slack.Lookups.lookup_user_name(user)
    channel_name = Slack.Lookups.lookup_channel_name(channel)
    send_message("ようこそ！#{username}さん、#{channel_name}へ！", channel, slack)
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
    IO.inspect Cinnamon.Handler.download_print_file(file_id)
    {:ok, state}
  end

  def handle_event(message = %{type: type}, slack, state) do
    IO.inspect message
    {:ok, state}
  end

  def handle_info(_, _, state), do: {:ok, state}
end
