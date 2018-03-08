defmodule BattleshipClient do

  def start(server_name) do

    Node.set_cookie(Node.self, :"test")

    case Node.connect(server_name) do
      true   -> :ok
      reason -> IO.puts "Could not connect to server, reason: #{reason}"
                System.halt(0)
    end
  end
end
