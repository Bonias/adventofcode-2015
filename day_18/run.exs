defmodule AdventOfCode do
  def run(dict, 0, _), do: dict
  def run(dict, steps, skip_corners) do
    dict = Enum.reduce 1..100, dict, fn x, odict ->
      Enum.reduce 1..100, odict, fn y, odict ->
        update_at_pos(odict, dict, {x, y})
      end
    end

    if skip_corners, do: dict = update_corners(dict)

    run(dict, steps - 1, skip_corners)
  end

  def get_neighbors(dict, {x, y}) do
    neighbors = [
      {x-1, y-1}, {x, y-1}, {x+1, y-1},
      {x-1, y  },           {x+1, y  },
      {x-1, y+1}, {x, y+1}, {x+1, y+1},
    ]
    for pos <- neighbors, do: dict[pos]
  end

  def update_corners(dict) do
    dict |> Dict.put({1,1}, 1) |> Dict.put({1,100}, 1) |> Dict.put({100,1}, 1) |> Dict.put({100,100}, 1)
  end

  def update_at_pos(dict, original_dict, pos) do
    val = dict[pos]
    new_val = get_neighbors(original_dict, pos) |> calculate_val(val)
    if val == new_val, do: dict, else: Dict.put(dict, pos, new_val)
  end

  def calculate_val(neighbors, 1) do
    on_count = Enum.filter(neighbors, &(&1 == 1)) |> Enum.count
    if on_count in [2, 3], do: 1, else: 0
  end

  def calculate_val(neighbors, 0) do
    on_count = Enum.filter(neighbors, &(&1 == 1)) |> Enum.count
    if on_count == 3, do: 1, else: 0
  end

  def count_lights(dict) do
    Enum.reduce 1..100, 0, fn x, sum ->
      Enum.reduce 1..100, sum, fn y, sum -> sum + dict[{x, y}] end
    end
  end
end

lines = "input" |> File.read! |> String.strip |> String.split("\n", trim: true)
grid = Enum.reduce Enum.with_index(lines), %{}, fn {line, x}, dict ->
  chars = String.split(line, "", trim: true)
  Enum.reduce Enum.with_index(chars), dict, fn {char, y}, dict ->
    Dict.put(dict, {x + 1, y + 1}, %{"#" => 1, "." => 0}[char])
  end
end

count = AdventOfCode.run(grid, 100, false) |> AdventOfCode.count_lights
IO.puts count

grid = AdventOfCode.update_corners(grid)
count = AdventOfCode.run(grid, 100, true) |> AdventOfCode.count_lights
IO.puts count