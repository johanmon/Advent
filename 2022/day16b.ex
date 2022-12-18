defmodule Day16b do

  def dynamic(t) do
    start = :AA
    ## map = Day16.sample(start)
    map = Day16.input(start)
    valves = Enum.map(map, fn({valve,_}) -> valve end)
    {max, _} = dynamic(t, {:pos, start}, {:pos, start}, valves, 1, 0, map, Map.new())
    max
  end

  def dynamic(0, _a, _b, _valves, _open, _rate, _map, mem) do
    ## :io.format("time-out\n")
    {0, mem}
  end    

  def dynamic(t, _a, _b, [], _open, rate, _, mem) do
    ## :io.format("all valves open\n")
    {t*rate, mem}
  end  

  def dynamic(t, a, b, valves, open, rate, map, mem) do
    case mem[{order(a, b), t, open}] do
      nil ->
	{max, mem} = elefant(t, a, b, valves, open, rate, map, mem)
	mem = Map.put(mem, {order(a, b), t, open}, max)
	{max, mem}
      max ->
	## :io.format("found ~w ~w ~w  max: ~w\n\n", [order(a,b), t, open, max])
	{max, mem}
    end
  end


  def elefant(t, {:tr, k, a}, elf, valves, open, rate, map, mem) do
    {max, mem} =  elf(t, step(k, a), elf, valves, [], open, rate, map, mem)
    {max + rate , mem}
  end

  def elefant(t, {:pos, a}, elf, valves, open, rate, map, mem) do
    {rt, tunnels} = map[a]

    ## open valve if possible
    {mx, mem} = if (Enum.member?(valves,a)) do
      removed = List.delete(valves, a)
      {mx, mem} = elf(t, {:pos,a}, elf, removed, [{a,rt}], open, rate, map, mem)
      {mx + rate, mem}
    else
      {0, mem}
    end

    Enum.reduce(tunnels, {mx, mem}, 
      fn({nxt, d}, {mx, mem}) ->
	## we need time to open and some time to flow i.e. d < t
        if (d < t) do
          ## moving to nxt
	  {my, mem} = elf(t, step(d, nxt), elf, valves, [], open, rate, map, mem)
	  my = my + rate
	  {max(mx,my), mem}
	else
	  {mx, mem}
	end
      end)
  end

  def elf(t, elef, elf, [], half, open, rate, map, mem) do
    {open, rate} = open(half, open, rate)
    dynamic(t-1, elef, elf, [], open, rate, map, mem)
  end
  
  def elf(t, elef, {:tr, k, a}, valves, half, open, rate, map, mem) do
    {open, rate} = open(half, open, rate)
    dynamic(t-1, step(k, a), elef, valves, open, rate, map, mem)
  end

  def elf(t, elef, {:pos, a}, valves, half, open, rate, map, mem) do
    {rt, tunnels} = map[a]

    ## open valve if possible
    {mx, mem} = if (Enum.member?(valves,a)) do
      removed = List.delete(valves, a)
      {open, rate} = open({a,rt}, half, open, rate)
      dynamic(t-1, elef, {:pos,a}, removed, open, rate, map, mem)
    else
      {0,mem}
    end

    Enum.reduce(tunnels, {mx, mem}, 
      fn({nxt, d}, {mx, mem}) ->
	## we need time to open and some time to flow i.e. d < t
        if (d < t) do
          ## moving to nxt
	  {open, rate} = open(half, open, rate)
	  {my, mem} = dynamic(t-1, elef, step(d, nxt), valves, open, rate, map, mem)
	  {max(mx,my), mem}
	else
	  {mx, mem}
	end
      end)
  end

											       
  def toggle(n) do rem(n+1,2) end

  def order({:tr, ka, a}, {:tr, kb, a}) when ka < kb do {{:tr, ka, a}, {:tr, kb, a}} end
  def order({:tr, ka, a}, {:tr, kb, a}) do {{:tr, kb, a}, {:tr, ka, a}} end        
  def order({:tr, ka, a}, {:tr, kb, b}) when a < b do {{:tr, ka, a}, {:tr, kb, b}} end    
  def order({:tr, ka, a}, {:tr, kb, b}) do {{:tr, kb, b}, {:tr, ka, a}} end    

  def order({:pos, a}, {:tr, k, b}) do {{:pos, a}, {:tr, k, b}} end
  def order({:tr, k, a}, {:pos, b}) do {{:pos, b}, {:tr, k, a}} end      
  def order({:pos, a}, {:pos, b}) when a < b do {{:pos, a}, {:pos, b}} end
  def order({:pos, a}, {:pos, b}) do {{:pos, b}, {:pos, a}} end  


  def open([], open, rate) do {open, rate} end  
  def open([{a,rt}], open, rate) do {insert(open, a), rate+rt} end

  
  def open({a,rt}, [], open, rate) do  {insert(open, a), rate+rt} end
  def open({a,rta}, [{b,rtb}], open, rate) do  {insert(insert(open, a), b), rate+rta+rtb} end
  
  def step(1, a) do {:pos, a}  end
  def step(k, a) do {:tr, k-1, a}  end

  def insert(k, valve) do
    k * prime(valve)
  end
  
  ## def insert([], valve) do [valve] end
  ## def insert([v|rest], valve) when v < valve do  [v|insert(rest, valve)] end
  ## def insert(open, valve) do  [valve|open] end


  def prime(valve) do
    case valve do 
      :AA -> 2 
      :AK -> 3
      :BB -> 5
      :BF -> 7
      :BV -> 11
      :CC -> 13
      :CN -> 17
      :DD -> 19
      :DS -> 23
      :EE -> 29
      :GB -> 31
      :GL -> 37
      :HH -> 41
      :IC -> 43
      :JJ -> 53
      :JH -> 59
      :KM -> 61
      :KT -> 67
      :NK -> 71
      :NT -> 73
      :OE -> 79
      :XC -> 83
    end
  end
    
end
