defmodule UI do

  def print(board) do
    y =
      for x <- 1..board.n,
          y <- 1..board.n,
          do: {{x, y}, 0}

    modified_map =
    board.map
    |> Enum.reduce( %{}, fn({{x,y}, value}, acc) -> Map.put(acc,{y,x},value) end)

    Map.new(y)
    |> Map.merge(modified_map)
    |> Enum.sort()
    |> Enum.map(fn {_, v} -> v end)
    |> Enum.chunk_every(board.n)
    |> IO.inspect

  end
end
