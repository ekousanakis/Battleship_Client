defmodule BattleshipClient do

  def join(server_name, username) do

     Node.set_cookie(Node.self, :"test")

    case Node.connect(server_name) do
      true   -> Process.send({:game_server ,server_name}, {:join, username}, [])
      reason -> IO.puts "Could not connect to server, reason: #{reason}"
    end

    # Ston Server:    iex --sname server -S mix

    # Ston client :   iex --sname cl1 -S mix
    #                 BattleshipClient.join(:"server@NT-21", "alex")









  end
end
