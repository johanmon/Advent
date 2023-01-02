defmodule Day19 do

  ##  Day 19, the first task was rather simple. Dynamic programming
  ##  solves the problem but I also added restrictions on which paths
  ##  to follow i.e. (big mistake) if you can build a geode robot - do
  ##  so as soon as you have the resources don't build a obsidian for
  ##  example and don't build a clay robot ... 
  ##
  ##  To solve the second part you need to cut branches early. One
  ##  solution is to keep track of the best solution so far and
  ##  determine that there is no way to find a better solution even if
  ##  you had unlimited of resources and could build a geode robot a
  ##  minute.
  ##
  ##  Why this task took me so long is that my assumption that it
  ##  would always pay off to build a geode robot as soon as possible,
  ##  never build a clay robot if you can build a obsidian robot
  ##  etc. It turns out that this is not the case but it works for the
  ##  samples. Realizing that this was a problem took some time :-)
  ##
  ##  The implementation generates the path and also uses a trail to
  ##  follow. The trail can be used for debugging by using a trail
  ##  that you know will generate a solution (for example the ones
  ##  give) and then see if and which restructions fail.
  ##
  ##  There is also a itertive procedure that starts searching down to
  ##  level 28 to find the best solution and then search deeper and
  ##  deeper (does not pay off but was good to have when dubugging).
  
  
  def task_a() do
    input() |>
      Enum.map(fn(r) -> parse(r) end)  |>
      Enum.map(fn(blue) -> quality(blue, 24) end) |>
      Enum.reduce(0, fn({g,i,_}, a) -> g*i+a end)
  end

  def task_b() do
    input() |>
      Enum.take(3) |>
      Enum.map(fn(r) -> parse(r) end)  |>
      Enum.map(fn(blue) ->
	{g,id,path} = quality(blue, 32)
	:io.format(" id = ~w, geode = ~w\n  path = ~w\n", [g, id, path])
	{g,id,path}
      end) |>
      Enum.reduce(1, fn({g,_,_}, a) -> g*a end)
  end  

  def debug(k, t, brk) do
    debug(k, t, brk, List.duplicate(:*, t))
  end
  
  def debug(k, t, brk, path) do
    {:ok, blue} = sample() |>
      Enum.map(fn(r) -> parse(r) end) |>
      Enum.fetch(k-1)
    quality(blue, t, brk, path)
  end
  
  def iterative(k) do
    {:ok, blue} = sample() |>
      Enum.map(fn(r) -> parse(r) end) |>
      Enum.fetch(k-1)
    iterative(28, blue, 0)
  end

  def iterative(blue, t) when t > 4 do 
    iterative(t-4, blue, 0)
  end
  
  def iterative(32, blue, brk) do
    {brk, id, path} = quality(blue, 32, brk, List.duplicate(:*, 32))
    :io.format("iterative: t = ~w,  brk = ~w\n", [32, brk])
    {brk, id, path}
  end
  def iterative(t, blue, brk) do
    {brk, _, _} = quality(blue, t, brk, List.duplicate(:*, t))
    :io.format("iterative: t = ~w,  brk = ~w\n", [t, brk])
    iterative(t+1, blue, brk)
  end

  def limit(k, t, brk)  do
    {:ok, blue} = sample() |>
      Enum.map(fn(r) -> parse(r) end) |>
      Enum.fetch(k-1)
    quality(blue, t, brk, List.duplicate(:*, t))
  end
  
  
  def quality(blue, t) do
    quality(blue, t, 0, List.duplicate(:*, t))
  end
  
  def quality({id, specs}, t, brk, nxts) do
    specs = specs(specs)
    {{geodes,path}, _} = dynamic(t, brk, {1,0,0,0}, {0,0,0,0}, specs, Map.new(), nxts)
    {geodes, id, path}
  end

  def dynamic(0, _, _robots, {_,_,_,geode}, _specs, mem, []) do 
    {{geode, []}, mem} 
  end

  def dynamic(t, brk, robots, resources, specs, mem, nxts) when t > 0 do

    case Map.get(mem, {t, robots, resources}) do
      nil ->
	{max, mem} = brk(t, brk, robots, resources, specs, mem, nxts)
	mem = Map.put(mem, {t, robots, resources}, max)
	{max, mem}
      max ->
	#:io.format(" break: ~w,  ~w,  ~w   max ~w\n", [t, robots, resources, max])
	{max, mem}
    end
  end

  def brk(t, brk, robots, resources, specs, mem, nxts) do

    geoder = elem(robots, 3)
    geode = elem(resources, 3)

    if (geode >= brk) do
      search(t, brk, robots, resources, specs, mem, nxts)
    else
      case t do
	1 -> if ( geoder < (brk-geode) ) do
      	  {{geode, []}, mem}
	else
	  search(t, brk, robots, resources, specs, mem, nxts)
	end
	t ->  if ( ((geoder*t) + (Enum.sum(1..(t-1)))) < (brk - geode))  do  
          {{geode, []}, mem}
	else
          search(t, brk, robots, resources, specs, mem, nxts)
	end
      end
    end
  end
  
  def search(t, brk, robots, resources, {orec, clayc, obsidianc, geodec}=specs, mem, [nxt|nxts]) do

    best = {0, []}
    
    {best, brk, mem} = if( afford(orec, resources) and next(nxt,:ore) ) do
      {{max, path}, mem} = dynamic(t-1, brk, build(:ore, robots), collect(robots, orec, resources), specs, mem, nxts)
      if max > brk do
	{{max, [:ore|path]}, max, mem}
      else
	{best, brk, mem}
      end
    else
      {best, brk, mem}
    end
    {best, brk, mem} = if( afford(clayc, resources) and  next(nxt,:clay)) do
      {{max,path}, mem} = dynamic(t-1, brk, build(:clay, robots), collect(robots, clayc, resources), specs, mem, nxts)
      if max > brk do
	{{max, [:clay|path]}, max, mem}
      else
	{best, brk, mem}
      end
    else
      {best, brk, mem}
    end
    {best,brk,mem} = if( afford(obsidianc, resources) and   !afford(geodec, resources) and  next(nxt,:obsidian)) do
      {{max,path}, mem} = dynamic(t-1, brk, build(:obsidian, robots), collect(robots, obsidianc, resources), specs, mem, nxts)
      if max > brk do
	{{max,[:obsidian|path]}, max, mem}
      else
	{best, brk, mem}
      end
    else
      {best, brk, mem}
    end
    {best,brk,mem} = if( afford(geodec, resources) and next(nxt,:geode)) do
      {{max,path}, mem} = dynamic(t-1, brk, build(:geode, robots), collect(robots, geodec, resources), specs, mem, nxts)
      if max > brk do
	{{max, [:geode|path]}, max, mem}
      else
	{best, brk, mem}
      end
    else
      {best, brk, mem}
    end
    {best, _, mem} = if(  !afford(geodec, resources) and next(nxt,:na) ) do  # 
      {{max,path}, mem} = dynamic(t-1, brk, robots, collect(robots, resources), specs, mem, nxts)
      if max > brk do
	{{max, [:na|path]}, max, mem}
      else
	{best, brk, mem}
      end
    else
      {best, brk, mem}
    end
    {best, mem}
  end

  def next(nxt, rob) do  (nxt == rob) or (nxt == :*)  end

  
  def cost(:ore, {ore, _, _, _}) do ore end
  def cost(:clay, {_, clay, _, _}) do clay end
  def cost(:obsidian, { _, _, obsidian, _}) do obsidian end
  def cost(:geode, {_, _, _, geode}) do geode end

  def build(:ore, {orer, clayr, obsr, geoder}) do {orer+1, clayr, obsr, geoder} end
  def build(:clay, {orer, clayr, obsr, geoder}) do {orer, clayr+1, obsr, geoder} end
  def build(:obsidian, {orer, clayr, obsr, geoder}) do  {orer, clayr, obsr+1, geoder} end
  def build(:geode, {orer, clayr, obsr, geoder}) do  {orer, clayr, obsr, geoder+1} end
    
  def afford({a0, b0, c0}, {a1,b1,c1,_}) do
    (a0 <= a1 and b0 <= b1 and c0 <= c1)
  end
  
  def collect({a0, b0, c0, d0}, {a1,b1,c1}, {ar,br,cr,dr}) do
    {ar+a0-a1, br+b0-b1, cr+c0-c1, dr+d0}
  end    
  
  def collect({a0, b0, c0, d0}, {ar,br,cr,dr}) do
    {ar+a0, br+b0, cr+c0, dr+d0}
  end    

  def specs([ore: ore, clay: clay, obsidian: obsi, geode: geode]) do
    {cost(ore), cost(clay), cost(obsi), cost(geode)}
  end

  def cost([ore: n]) do {n,0,0} end
  def cost([clay: n]) do {0,n,0} end  
  def cost([obsidian: n]) do {0,0,n} end  

  def cost([ore: o, clay: c]) do {o,c,0} end
  def cost([ore: o, obsidian: s]) do {o,0,s} end


  def solutions() do
    {[:na,       :na,    :na,    :na,       :ore,   :na,       :clay,     :clay,  :clay,     :clay,
     :clay,     :clay,  :clay,  :obsidian, :na,    :obsidian, :obsidian, :na,    :obsidian, :geode,
     :obsidian, :geode, :geode, :geode,    :na,    :geode,    :geode,    :na,    :geode,    :geode,
      :geode,    :na],
     [:na,   :na,   :ore, :na, :ore, :clay, :clay, :clay, :clay, :clay,
      :obsidian, :clay, :obsidian, :obsidian, :obsidian, :ore, :obsidian, :obsidian, :geode, :geode,
      :obsidian, :geode, :obsidian, :geode, :geode, :clay, :geode, :geode,  :clay, :geode,
      :geode, :clay],
     [:na, :na, :na, :na, :ore, :na, :na, :ore, :na, :clay, :ore, :clay, :clay, :clay, :clay, :clay, :obsidian, :clay, :obsidian, :ore, :obsidian, :clay, :obsidian, :clay, :geode, :obsidian, :obsidian, :obsidian, :geode, :ore, :geode, :ore],
     [:na, :na, :na, :ore, :na, :ore, :na, :clay, :clay, :clay, :clay, :clay, :clay, :clay, :obsidian, :clay, :clay, :obsidian, :clay, :obsidian, :clay, :obsidian, :geode, :obsidian, :obsidian, :geode, :obsidian, :geode, :obsidian, :geode, :geode, :ore],
     [:na, :na, :na, :na, :ore, :na, :na, :ore, :na, :ore, :clay, :clay, :clay, :clay, :clay, :clay, :obsidian, :clay, :obsidian, :obsidian, :obsidian, :obsidian, :obsidian, :geode, :ore, :obsidian, :geode, :obsidian, :geode, :ore, :geode, :ore]}
  end
  
  
  def input() do
    File.stream!("day19.csv")
  end

  def sample() do
    ["Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.",
     "Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian.",
     "Blueprint 3: Each ore robot costs 4 ore. Each clay robot costs 4 ore. Each obsidian robot costs 4 ore and 14 clay. Each geode robot costs 3 ore and 16 obsidian.",
     "Blueprint 4: Each ore robot costs 3 ore. Each clay robot costs 3 ore. Each obsidian robot costs 2 ore and 19 clay. Each geode robot costs 2 ore and 12 obsidian.",
     "Blueprint 5: Each ore robot costs 4 ore. Each clay robot costs 4 ore. Each obsidian robot costs 4 ore and 9 clay. Each geode robot costs 4 ore and 16 obsidian."
    ]
  end

  

  
  def parse(line) do
    [blue | specs] = String.split(String.trim(line), [":", "."])
    [_,nr] =  String.split(blue, [" "])
    {nr, _} = Integer.parse(nr)
    {nr, parse_specs(specs)}
  end

  def parse_specs([""]) do [] end  
  def parse_specs([spec|rest]) do
    [robot, costs] = String.split(spec, " costs ")
    [ _, _, name |_] = String.split(robot, " ")
    costs = Enum.map(String.split(costs, " and "), fn(cost) -> parse_cost(cost) end)
    [{String.to_atom(name), costs}| parse_specs(rest)]
  end

  def parse_cost(cost) do
    [cost, item] = String.split(cost, " ")
    {cost,_} = Integer.parse(cost)
    {String.to_atom(item), cost}
  end
  

  

end
