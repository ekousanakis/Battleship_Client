defmodule BattleshipClient do

  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__,nil, name: :client)
  end

  def init(_) do
    {:ok, nil}
  end

  def join(server_name, username) do

     Node.set_cookie(Node.self, :"test")

    case Node.connect(server_name) do
      true   -> Process.send({:game_server ,server_name}, {:join_game, username, Node.self, self()}, [])
      reason -> IO.puts "Could not connect to server, reason: #{reason}"
    end


    
    # Ston Server:    iex --sname server -S mix

    # Ston client :   iex --sname cl1 -S mix
    #                 BattleshipClient.join(:"server@NT-21", "alex")
  end

  def handle_cast(:wait, state) do
    IO.puts "Connected, waiting for other player..."
    {:noreply, state}
  end


end
