defmodule Day16a do

  def dynamic(t) do
    start = :AA
    ##map = Day16.sample(start)
    map = Day16.input(start)
    valves = Enum.map(map, fn({valve,_}) -> valve end)
    {max, _, path} = dynamic(start, t, valves, [], 0, map, Map.new(), [])
    {max, Enum.reverse(path)}
  end

  def dynamic(_, 0, _, _, _, _, _, mem, path) do
    ## :io.format("time-out: \n")
    {0, mem, path}
  end  
  def dynamic(valve, t, [], open, rate, _, mem, path) do
    total = rate * t
    ## :io.format("all open: ~w\n", [total])
    mem = Map.put(mem, {valve, t, open}, {total,path})
    {total, mem, path}
  end
  def dynamic(valve, t, valves, open, rate, map, mem, path) do
    case mem[{valve, t, open}] do
      nil ->
	## :io.format("searching ~w ~w ~w\n", [valve, t, open])
	{max, mem, path} = search(valve, t, valves, open, rate, map, mem, path)
	mem = Map.put(mem, {valve, t, open}, {max,path})
	{max, mem, path}
      {max, path} ->
	{max, mem, path}
    end
  end


  ##  t > 0 , valves =/= [] i.e. we still have a choice
  ##      - open valve if possible
  ##      - move thriugh nay of tunnels
  ##
  
  def search(valve, t, valves, open, rate, map, mem, path) do

    {rt, tunnels} = map[valve]
    
    {mx, mem, pathx} = if Enum.member?(valves, valve) do
      ## open the valve is one option
      removed = List.delete(valves, valve)
      {mx, mem, pathx} = dynamic(valve, t-1, removed, insert(open, valve), rate+rt, map, mem, [valve|path])
      mx = mx + rate
      {mx, mem, pathx}
    else
      ## if we can not open the valve we could just stay
      {rate*t, mem, path}
    end

    Enum.reduce(tunnels, {mx, mem, pathx}, 
      fn({nxt, d}, {mx, mem, pathx}) ->
        if (d < t) do
          ## moving to nxt 
	  {my, mem, pathy} = dynamic(nxt, t-d, valves, open, rate, map, mem, path)
	  my = my + (rate *d)
	  if (my > mx) do
	    ## moving to nxt was better
	    {my, mem, pathy}
	  else
	    {mx, mem, pathx}
	  end
	else
	  {mx, mem, pathx}
	end
      end)
  end

  def insert([], valve) do [valve] end
  def insert([v|rest], valve) when v < valve do  [v|insert(rest, valve)] end
  def insert(open, valve) do  [valve|open] end


end
