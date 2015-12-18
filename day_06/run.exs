defmodule AdventOfCode do
  def parse_lines(lines) do
    for line <- lines do
      captures = Regex.named_captures(~r/(?<type>toggle|turn on|turn off) (?<x1>\d+),(?<y1>\d+) through (?<x2>\d+),(?<y2>\d+)/, line)
      %{
         type: captures["type"],
         x1: String.to_integer(captures["x1"]),
         x2: String.to_integer(captures["x2"]),
         y1: String.to_integer(captures["y1"]),
         y2: String.to_integer(captures["y2"])
       }
    end
  end

  def gen_list(0, _), do: []
  def gen_list(size, val), do: [val | gen_list(size - 1, val)]

  def run(commands, list, fun) do
    Enum.reduce commands, list, fn command, list ->
      %{ x1: x1, x2: x2, y1: y1, y2: y2 } = command
      run_for_column({x1, y1, x2, y2}, list, fun.(command.type), 0)
    end
  end

  defp run_for_column(_, [], _fun, _y), do: []
  defp run_for_column({x1, y1, x2, y2}, [head | tail], fun, y) when y1 <= y and y <= y2 do
    [run_for_row({x1, x2}, head, fun, 0) | run_for_column({x1, y1, x2, y2}, tail, fun, y + 1)]
  end
  defp run_for_column({x1, y1, x2, y2}, [head | tail], fun, y) do
    [head | run_for_column({x1, y1, x2, y2}, tail, fun, y + 1)]
  end

  defp run_for_row(_, [], _fun, _x), do: []
  defp run_for_row({x1, x2}, [head | tail], fun, x) when x1 <= x and x <= x2 do
    [fun.(head) | run_for_row({x1, x2}, tail, fun, x + 1)]
  end
  defp run_for_row({x1, x2}, [head | tail], fun, x) do
    [head | run_for_row({x1, x2}, tail, fun, x + 1)]
  end
end

lines = "input" |> File.read! |> String.strip |> String.split("\n", trim: true)
commands = AdventOfCode.parse_lines(lines)

list = AdventOfCode.gen_list(1000, 0)
list = AdventOfCode.gen_list(1000, list)

map = AdventOfCode.run commands, list, fn type ->
  case type do
    "toggle"   -> fn val -> %{0 =>  1, 1 => 0}[val] end
    "turn on"  -> fn _ -> 1 end
    "turn off" -> fn _ -> 0 end
  end
end
IO.puts map |> Enum.map(fn l -> Enum.sum(l) end) |> Enum.sum

map = AdventOfCode.run commands, list, fn (type) ->
  case type do
    "toggle"   -> &(&1 + 2)
    "turn on"  -> &(&1 + 1)
    "turn off" -> &(Enum.max([0, &1 - 1]))
  end
end
IO.puts map |> Enum.map(fn l -> Enum.sum(l) end) |> Enum.sum
