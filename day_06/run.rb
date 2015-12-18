lines = File.read('input').strip.split("\n")
commands = lines.map do |line|
  match = line.match(/(turn on|turn off|toggle) (\d+),(\d+) through (\d+),(\d+)/)
  {
    type: match[1].to_sym,
    from: { x: match[2].to_i, y: match[3].to_i },
    to:   { x: match[4].to_i, y: match[5].to_i }
  }
end

def run(commands, grid)
  commands.each do |command|
    type, from, to = command.values_at(:type, :from, :to)
    (from[:y]..to[:y]).each do |j|
      (from[:x]..to[:x]).each do |i|
        grid[j][i] = yield(type, grid[j][i])
      end
    end
  end
end

grid = Array.new(1000) { Array.new(1000, 0) }
run commands, grid do |type, value|
  case type
  when :'toggle'   then { 1 => 0, 0 => 1 }[value]
  when :'turn on'  then 1
  when :'turn off' then 0
  end
end
puts grid.flatten.reduce(0, &:+)

grid = Array.new(1000) { Array.new(1000, 0) }
run commands, grid do |type, value|
  case type
  when :'toggle'   then value + 2
  when :'turn on'  then value + 1
  when :'turn off' then value == 0 ? 0 : value - 1
  end
end
puts grid.flatten.reduce(0, &:+)
