defmodule BattleshipClient do
    # Ston Server:    iex --sname server -S mix

    # Ston client :   iex --sname cl1 -S mix
    #                 BattleshipClient.join(:"server@NT-21", "alex")
  use GenServer

  @server_name :"server@NT-20"

  defstruct [:game_pid, :my_board, :shot_board]
  @type t :: %__MODULE__{ game_pid:   nil,
                          my_board:   Board.t(),
                          shot_board: Board.t()}

  def start_link(_) do
    GenServer.start_link(__MODULE__,nil, name: :client)
  end

  def init(_) do
    {:ok, %BattleshipClient{game_pid: nil, my_board: nil, shot_board: nil}}
  end

  def join_server_as(username) do
    GenServer.cast(:client, {:connect, username})
  end

  def next_move(x, y) do
    GenServer.call(:client, {:next_move, x, y})
  end

  def handle_cast({:connect, username}, state) do
    Node.set_cookie(Node.self, :"test")
    case Node.connect(@server_name) do
      true   ->
        IO.inspect(self(), label: "I AM")
        Process.send({:game_server ,@server_name}, {:join_game, username, Node.self, self()}, [])
      reason -> IO.puts "Could not connect to server, reason: #{reason}"
    end
    {:noreply, state}
  end

  def handle_call({:next_move, x, y}, _from, state) do
    Process.send(state.game_pid, {:make_move, x, y, self()}, [])
    {:reply, state, state}
  end

  def handle_info("HAHAHAHA", state) do
    IO.puts("server laughs at us!")
    {:noreply, state}
  end

  def handle_info({:init_data, board}, state) do

    player_boards = %{ state |  my_board: board,
                                shot_board: Board.new(board.n) }

    {:noreply, player_boards}
  end

  def handle_info({:game_created, game_pid}, state) do
    IO.puts "joined game with pid: #{inspect game_pid}"
    {:noreply, %{state | game_pid: game_pid}}
  end

  def handle_info(:alone, state) do
      IO.puts "Connected, waiting for other player..."
      {:noreply, state}
  end
  def handle_info(:not_unique, state) do
      IO.puts "Username already exists..."
      {:noreply, state}
  end

  def handle_info(message, player_boards) do
      case message do
        :game_ended               -> IO.puts "The game has ended"
        :out_of_bounds            -> IO.puts "Your shot was out of bounds"
        :already_shot             -> IO.puts "You have already made this shot"
        :miss                     -> IO.puts "Your shot was a miss"
        {:winner, winner}         -> IO.puts "The winner is #{winner}"
        {:hit , player}           -> IO.puts "#{player} 's shot was a hit"
        :your_turn                -> IO.puts "It's your turn to play now..."
        :not_your_turn            -> IO.puts "Move canceled, not your turn..."
      end
      UI.print(player_boards.my_board)
      UI.print(player_boards.shot_board)
    {:noreply, player_boards}
  end

end
