defmodule ReactionCache.Cache do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [
      {:ets_table_name, :link_cache_table},
      {:log_limit, 1_000_000}
      ], opts)
  end
  def create_reaction(data) do
    %{"content_id" => content_id} = data
    case get_reaction(content_id) do
      {:not_found} -> set_reaction(data)
      {:found, result} -> update_reaction(result, data)
    end

  end

  def get_reaction(content_id) do
    case GenServer.call(__MODULE__, {:get, content_id}) do
      [] -> {:not_found}
      [{_content_id, result}] -> {:found, result}
    end
  end

  def set_reaction(data) do
    %{"content_id" => content_id, "user_id" => user_id, "type" => type} = data
    value = %{ users: %{user_id => type}, num_of_reactions: 1}
    GenServer.call(__MODULE__, {:set, content_id, value})
    value
  end

  defp update_reaction(result, data) do
    %{"content_id" => content_id, "user_id" => user_id, "type" => type} = data
    %{users: users, num_of_reactions: num_of_reactions} = result

    # Update the number of reactions if user does not exist
    current_num_of_reactions = if (Map.get(users, user_id) == nil), do: num_of_reactions + 1, else: num_of_reactions

    # Create user or aupdate user's reaction
    current_num_of_users = Map.merge(users, %{user_id => type})

    value = %{ users: current_num_of_users, num_of_reactions: current_num_of_reactions}

    GenServer.call(__MODULE__, {:set, content_id, value})

    value

  end

  # GenServer callbacks

  def handle_call({:get, content_id}, _from, state) do
    %{ets_table_name: ets_table_name} = state
    result = :ets.lookup(ets_table_name, content_id)
    {:reply, result, state}
  end

  def handle_call({:set, content_id, value}, _from, state) do
    %{ets_table_name: ets_table_name} = state
    true = :ets.insert(ets_table_name, {content_id, value})
    {:reply, value, state}
  end

  def init(args) do
    [{:ets_table_name, ets_table_name}, {:log_limit, log_limit}] = args

    :ets.new(ets_table_name, [:named_table, :set, :private])

    {:ok, %{log_limit: log_limit, ets_table_name: ets_table_name}}
  end
end
