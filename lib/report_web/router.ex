defmodule ReportWeb.Router do
  use ReportWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ReportWeb do
    pipe_through :api

    post "/reaction", ReportController, :reaction

    get "/reaction_counts/:content_id", ReportController, :reaction_count

  end
end
