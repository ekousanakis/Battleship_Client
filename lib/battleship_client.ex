defmodule BattleshipClient do
    # Ston Server:    iex --sname server -S mix

    # Ston client :   iex --sname cl1 -S mix
    #                 BattleshipClient.join(:"server@NT-21", "alex")
  use GenServer

  @server_name :"server@NT-20"

  defstruct [:game_pid, :username, :my_board, :shot_board]
  @type t :: %__MODULE__{ game_pid:   nil,
                          username:   nil,
                          my_board:   Board.t(),
                          shot_board: Board.t()}

  def start_link(_) do
    GenServer.start_link(__MODULE__,nil, name: :client)
  end

  def init(_) do
    {:ok, %BattleshipClient{game_pid: nil, username: nil, my_board: nil, shot_board: nil}}
  end

  def join_server_as(username) do
    GenServer.cast(:client, {:connect, username})
  end

  def next_move(x, y) do
    GenServer.cast(:client, {:next_move, x, y})
  end

  def handle_cast({:connect, username}, state) do
    Node.set_cookie(Node.self, :"test")
    case Node.connect(@server_name) do
      true   ->
        Process.send({:game_server ,@server_name}, {:join_game, username, Node.self, self()}, [])
      reason -> IO.puts "Could not connect to server, reason: #{reason}"
    end
    {:noreply, %{state | username: username}}
  end

  def handle_cast({:next_move, x, y}, state) do
    Process.send(state.game_pid, {:make_move, x, y, self()}, [])
    {:noreply, state}
  end

  def handle_info({:init_data, board}, state) do

    player_boards = %{ state |  my_board: board,
                                shot_board: Board.new(board.n) }

    {:noreply, player_boards}
  end

  def handle_info({:game_created, game_pid}, state) do
    IO.puts "joined game with pid: #{inspect game_pid}"
    UI.print(state.my_board)
    UI.print(state.shot_board)

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
  def handle_info({hit_or_miss , player, board}, state) do
    state =
    case player == state.username do
      true    ->  IO.puts "Your shot was a #{hit_or_miss}"
                  %{ state | shot_board: board}
      false   ->  IO.puts  "#{player} 's shot was a #{hit_or_miss}"
                  %{ state | my_board: board}
    end
    UI.print(state.my_board)
    UI.print(state.shot_board)
    {:noreply, state}
  end


  def handle_info(message, state) do
      case message do
        :game_ended               -> IO.puts "The game has ended"
        :out_of_bounds            -> IO.puts "Your shot was out of bounds"
        :already_shot             -> IO.puts "You have already made this shot"
        {:winner, winner}         -> IO.puts "The winner is #{winner}"
        :your_turn                -> IO.puts "It's your turn to play now..."
        :not_your_turn            -> IO.puts "Move canceled, not your turn..."
      end
    {:noreply, state}
  end

end
