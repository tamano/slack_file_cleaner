defmodule SlackFileCleaner do
  @moduledoc """
  Remove all files uploaded to Slack
  """

  def main(args) do
    {options, _, _} = OptionParser.parse(
      args,
      switches: [token: :string, before: :integer, dryrun: :boolean],
      aliases: [t: :token, b: :before]
    )

    IO.puts("** Start searching target files")

    target_file_ids(options)
    |> fn(f) ->
        # FIXME: maybe this is not a good way
        IO.puts("** Start deleting #{Enum.count(f)} files #{if options[:dryrun] == true, do: "(dry run)"}")
        f
      end.()
    |> Enum.map( fn(file_id) ->
      delete_file(options, file_id)
      # didn't make it parallel to prevent from hitting API limit.
      # spawn(fn -> delete_file(options, file_id) end)
      end)
  end

  defp target_file_ids(options) do
    # fetch for the max page number at first for recursive process
    get_max_page(options)
    |> list_file_ids(options, [])
  end

  defp get_max_page(options) do
    fetch_file_list(options)
    |> json_paging_max
  end

  # recursive processing from the last page to the first
  # counting down from the last page makes easy to handle the final process
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

  defp delete_file(options, file_id) do
    if options[:dryrun] do
      IO.puts("Deleting file: #{file_id} (dry run)")
    else
      "https://slack.com/api/files.delete?token=#{options[:token]}&file=#{file_id}"
      |> HTTPoison.post!([])
      |> http_body
      |> Poison.decode!
      |> json_delete_result
      |> fn(result) -> IO.puts("Deleting file: #{file_id} (#{result})") end.()
    end
  end

  defp http_body( %{ status_code: 200, body: json} ), do: json
  defp http_body( %{ status_code: 429, body: json} ), do: json   # rate limit
  defp json_paging_max( %{ "ok" => true, "paging" => %{"pages" => max} } ), do: max
  defp json_files( %{ "ok" => true, "files" => body } ), do: body
  defp json_delete_result( %{ "ok" => true } ), do: "success"
  defp json_delete_result( %{ "ok" => false, "error" => body} ), do: "error: #{body}"

  defp file_ids([], ids), do: ids
  defp file_ids([ head | tail],  ids) do
    %{ "id" => file_id } = head
    file_ids(tail, [file_id] ++ ids)
  end

end
