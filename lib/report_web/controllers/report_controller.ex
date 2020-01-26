defmodule ReportWeb.ReportController do
  use ReportWeb, :controller

  def reaction(conn, _params) do

    ReactionCache.Cache.create_reaction(conn.body_params)

    conn
    |> put_status(201)
    |> json(
      %{success: true}
    )

  end

  def reaction_count(conn, %{"content_id" => content_id}) do
    ractions = ReactionCache.Cache.get_reaction(content_id)

    case ractions do
      {:not_found} ->
        conn
        |> put_status(404)
        |> json(%{})
      {:found, result} ->
        %{num_of_reactions: num_of_reactions} = result
        conn
        |> put_status(404)
        |> json(%{
          content_id: content_id,
          reaction_count: %{fire: num_of_reactions}
        })
    end
  end

end
