defmodule NailbitersWeb.PageController do
  use NailbitersWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
