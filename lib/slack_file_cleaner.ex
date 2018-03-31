defmodule SlackFileCleaner do
  @moduledoc """
  Remove all files uploaded to Slack
  """

  def main(args) do
    {options, _, _} = OptionParser.parse(
      args,
      switches: [token: :string, before: :integer],
      aliases: [t: :token, b: :before]
    )

    Enum.each(target_file_ids(options), &(IO.puts(&1)) )
  end

  defp target_file_ids(options) do
    get_max_page(options)
    |> list_file_ids(options, [])
  end

  defp get_max_page(options) do
    fetch_file_list(options)
    |> json_paging_max
  end

  defp list_file_ids(0, _, ids), do: ids
  defp list_file_ids(page, options, ids) do
    IO.puts("retriving page: #{page}")

    new_ids = fetch_file_list(options, page)
              |> json_files
              |> file_ids([])

    list_file_ids(page-1, options, new_ids ++ ids)
  end

  defp fetch_file_list(options, page \\ 1) do
    "https://slack.com/api/files.list?token=#{options[:token]}&ts_to=#{options[:before]}&page=#{page}"
    |> HTTPoison.get!
    |> http_body
    |> Poison.decode!
  end

  defp http_body( %{ status_code: 200, body: json} ), do: json
  defp json_paging_max( %{ "ok" => true, "paging" => %{"pages" => max} } ), do: max
  defp json_files( %{ "ok" => true, "files" => body } ), do: body

  defp file_ids([], ids), do: ids
  defp file_ids([ head | tail],  ids) do
    %{ "id" => file_id } = head
    file_ids(tail, [file_id] ++ ids)
  end
end
