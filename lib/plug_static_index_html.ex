defmodule Plug.Static.IndexHtml do
  @behaviour Plug
  @moduledoc """
  Serves `index.html` pages for requests to paths without a filename in Plug applications.
  """

  @doc ~S"""
  Initialize plug options

   - at: The request path to reach for static assets, defaults to "/"
   - default_file: Filename to serve when request path is a directory, defaults to "index.html"

  ## Example

      iex> Plug.Static.IndexHtml.init(at: "/doc")
      [matcher: ~r|^.*/[^.]*$|, default_file: "index.html"]
  """
  def init([]), do: init(at: "/")
  def init(at: path), do: init(at: path, default_file: "index.html")

  def init(at: path, default_file: filename) do
    [matcher: ~r|^.*/[^.]*$|, default_file: filename]
  end

  @doc """
  Invokes the plug, adding default_file to request_path and path_info for directory paths

  ## Example

      iex> opts = Plug.Static.IndexHtml.init(at: "/doc")
      iex> conn = %Plug.Conn{request_path: "/doc/a/", path_info: ["doc", "a"]}
      iex> Plug.Static.IndexHtml.call(conn, opts) |> Map.take([:request_path, :path_info])
      %{path_info: ["doc", "a", "index.html"], request_path: "/doc/a/index.html"}
  """
  def call(conn, matcher: pattern, default_file: filename) do
    if String.match?(conn.request_path, pattern) do
      %{
        conn
        | request_path: "#{String.trim_trailing(conn.request_path, "/")}/#{filename}",
          path_info: conn.path_info ++ [filename]
      }
    else
      conn
    end
  end
end
