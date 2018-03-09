defmodule BattleshipClient do

  use GenServer

  @server_name :"server@NT-21"
  def start_link(_) do
    GenServer.start_link(__MODULE__,nil, name: :client)
  end

  def init(_) do

    {:ok, nil}
  end

  def join_server_as(username) do
    Node.set_cookie(Node.self, :"test")
    case Node.connect(@server_name) do
      true   -> Process.send({:game_server ,@server_name}, {:join_game, username, Node.self, self()}, [])
      reason -> IO.puts "Could not connect to server, reason: #{reason}"
    end

    # Ston Server:    iex --sname server -S mix

    # Ston client :   iex --sname cl1 -S mix
    #                 BattleshipClient.join(:"server@NT-21", "alex")
  end

  def next_move(x, y) do
    state = GenServer.call(:client, :get)
    Process.send(state, {:make_move, x, y, Node.self()}, [])
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  def handle_info(:alone, state) do
    IO.puts "Connected, waiting for other player..."
    {:noreply, state}
  end

  def handle_info(:game_ended, state) do
    IO.puts "The game has ended"
    {:noreply, state}
  end

  def handle_info(:out_of_bounds, state) do
    IO.puts "Your shot was out of bounds"
    {:noreply, state}
  end

  def handle_info(:already_shot, state) do
    IO.puts "You have already made this shot"
    {:noreply, state}
  end

  def handle_info(:miss, state) do
    IO.puts "Your shot was a miss"
    {:noreply, state}
  end
   
  def handle_info({:winner, winner}, state) do
    IO.puts "The winner is #{winner}"
    {:noreply, state}
  end

  def handle_info({:hit , player}, state) do
    IO.puts "#{player} 's shot was a hit"
    {:noreply, state}
  end
  
  def handle_info(:your_turn, state) do
    IO.puts "It's your turn to play now..."
    {:noreply, state}
  end

  def handle_info(:not_your_turn, state) do
    IO.puts "Move canceled, not your turn..."
    {:noreply, state}
  end

  def handle_info(:not_unique, state) do
    IO.puts "Username already exists"
    {:noreply, state}
  end

   def handle_info({:game_created, game_pid}, state) do
    IO.puts "joined game with pid: #{inspect game_pid}"
    {:noreply, game_pid}
  end

  def handle_info({:move_completed, x, y}, state) do
    IO.puts "move completed: #{x} #{y}"
    {:noreply, state}
  end

end
