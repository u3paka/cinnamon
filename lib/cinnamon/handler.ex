defmodule Cinnamon.Handler do

  use Slack

  def message("(" <> cmd, channel, slack) do
    command cmd
  end

  def message(text, channel, slack) do
    do_message(text)
  end

  def command(cmd) do
   cmd
  end

  def print(path, word) when word in ["doc", "docx"] do
    new_path = path
    |> Path.rootname
    |> Kernel.<>(".pdf")

    "soffice"
    |> System.find_executable()
    |> System.cmd(["--headless", "-o #{new_path}", "--convert-to", "pdf", path])
  end

  def print(path, filetype) do
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
  end

  def download_file(file_id, out_dir \\ "tmp") do
    case Slack.Web.Files.info(file_id) do
      %{"file" => %{"url_private_download" => url, "user" => user, "name" => name, "filetype": filetype}} = result ->
        headers = ["Authorization": "Bearer #{Application.get_env(:cinnamon, :slack_token)}"]
        %HTTPoison.Response{body: body} = HTTPoison.get!(url, headers)
        "./#{out_dir}/#{user}/#{name}"
        |> save_file(body)
        |> case do
             {:ok, path} -> print(path, filetype)
             err -> IO.inspect err
           end
      error ->
        IO.inspect error
    end
  end

  def save_file(path, body) do
    path
    |> Path.dirname
    |> File.mkdir_p
    |> case do
         :ok ->
           File.write!(path, body)
           {:ok, path}
         error ->
           {:error, error}
       end
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
