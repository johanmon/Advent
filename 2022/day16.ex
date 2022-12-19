defmodule Day16 do

  def input(start) do
    File.stream!("day16.csv") |>
      parse() |>
      map(start)
  end

  def sample(start) do
    test() |>
      parse() |>
      map(start)
  end
  
  def debug() do
    map(parse(test()), :AA)
  end

  def map(input, start) do
    all = Enum.map(input, fn({valve, rate, valves}) ->
      {valve, rate, Enum.map(valves, fn(vl) -> {vl, 1} end)}
    end)
    {valves, conn} = Enum.split_with(all,  fn({valve,rate,_}) -> (rate != 0) or (valve == start) end)

    extended = extend(conn, conn)    
    
    map = Enum.reduce(extended, valves, fn({v0,_, t0}, valves) ->
      extend(valves, v0, t0)
    end)

    map = if List.keymember?(map, start, 0) do
      map
    else
      [List.keyfind(extended, start, 0) | map]
    end

    Enum.reduce(map, Map.new(), fn({valve, rate, tunnels}, map) ->
      Map.put(map, valve, {rate, tunnels})
    end)

  end

  def short(map, valve) do
    {_, tunnels} = Map.get(map, valve)
    map = Map.delete(map, valve)
    lst = Map.to_list(map)
    Enum.reduce(extend(Enum.map(lst, fn({v, {r, t}}) ->
	      {v, r, t} end),
	  valve, tunnels),
      Map.new(),
      fn({v,r,t}, map) -> Map.put(map, v, {r,t}) end)
  end

  def extend([], extended) do Enum.reverse(extended) end  
  def extend([{v,_,t}|rest], extended) do
    extend(extend(rest, v, t), extend(extended, v, t))
  end

  def extend(conn, v0, t0) do
    Enum.map(conn, fn({v1,r1,t1}) ->
      extended = extend(v1, t1, v0, t0)
      {v1, r1, extended}
    end)
  end

  def extend(v1,t1, v0, t0) do
      case List.keyfind(t1, v0, 0) do
	{v0, _k0} ->
	  removed = List.keydelete(t1, v0, 0)
	  Enum.reduce(t0, removed, fn({v2,k2}, acc) ->
	    if (v2 != v1 ) do
	      case List.keyfind(removed, v2, 0) do
		{v2,k3} ->
		  [{v2, min(k3, k2+1)}|List.keydelete(acc, v2,0)]
		nil ->
		  [{v2, k2+1}|acc]
	      end
	    else
	      acc
	    end
	  end)
	nil ->
	  t1
      end
  end
  

  def parse(input) do
    Enum.map(input, fn(row) ->
      [valve, rate, valves] = String.split(String.trim(row), ["=", ";"])
      [_, valve | _ ] = String.split(valve, [" "])
      valve = String.to_atom(valve)
      {rate,_} = Integer.parse(rate)
      [_,_,_,_, _| valves] = String.split(valves, [" "])
      valves = Enum.map(valves, &String.to_atom(String.trim(&1,",")))
      {valve, rate, valves}
    end)
  end


  def test() do
    ["Valve AA has flow rate=0; tunnels lead to valves DD, II, BB",
     "Valve BB has flow rate=13; tunnels lead to valves CC, AA",
     "Valve CC has flow rate=2; tunnels lead to valves DD, BB",
     "Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE",
     "Valve EE has flow rate=3; tunnels lead to valves FF, DD",
     "Valve FF has flow rate=0; tunnels lead to valves EE, GG",
     "Valve GG has flow rate=0; tunnels lead to valves FF, HH",
     "Valve HH has flow rate=22; tunnel leads to valve GG",
     "Valve II has flow rate=0; tunnels lead to valves AA, JJ",
     "Valve JJ has flow rate=21; tunnel leads to valve II"]
  end
							    

end
