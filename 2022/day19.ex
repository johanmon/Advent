defmodule Day19 do

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
      Enum.map(fn(blue) -> quality(blue, 32) end) |>
      Enum.reduce(0, fn({g,i,_}, a) -> g*i+a end)
  end  

  def debug(k, t) do
    debug(k, t, List.duplicate(:*, t))
  end
  
  def debug(k, t, path) do
    {:ok, blue} = sample() |>
      Enum.map(fn(r) -> parse(r) end) |>
      Enum.fetch(k)
    quality(blue, t, path)
  end

  def quality(blue, t) do
    quality(blue, t, List.duplicate(:*, t))
  end
  
  def quality({id, specs}, t, nxts) do
    specs = specs(specs)
    {{geodes,path}, _} = dynamic(t, 0, {1,0,0,0}, {0,0,0,0}, specs, Map.new(), nxts)
    :io.format(" ~w  ~w \n", [id, geodes])
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
	{max, mem}
    end
  end

  def brk(t, brk, {_orer, _clayr, _obsidianr, geoder}=robots, {_ore, clay, obsidian, geode}=resources, {_, _, _, {_,cc,oc}}=specs, mem, nxts) do

    case t do
      1 -> if ( geoder < (brk-geode)) do
      	{{geode, []}, mem}
      else
	search(t, brk, robots, resources, specs, mem, nxts)
      end
      2 -> if ( ((geoder*2) < (brk-geode)) or (((geoder*2) < (brk-geode-1)) and clay >= cc and obsidian >= oc) ) do
      	{{geode, []}, mem}
      else
	search(t, brk, robots, resources, specs, mem, nxts)
      end
      3 -> if ( ((geoder*3) < (brk-geode-1)) or (((geoder*3) < (brk-geode-3)) and clay >= cc and obsidian >= oc) ) do
      	{{geode, []}, mem}
      else
	search(t, brk, robots, resources, specs, mem, nxts)
      end
      4 -> if ( ((geoder*4) < (brk-geode-3)) or  (((geoder*4) < (brk-geode-6)) and clay >= cc and obsidian >= oc)     ) do
      	{{geode, []}, mem}
      else
	search(t, brk, robots, resources, specs, mem, nxts)
      end
      t -> if ( ((geoder*t) < (brk-geode-(Enum.sum(1..(t-2))))) or (((geoder*t) < (brk-geode-Enum.sum(1..(t-1)) )) and clay >= cc and obsidian >= oc))  do  
      	{{geode, []}, mem}
      else
      	search(t, brk, robots, resources, specs, mem, nxts)
      end
    end
    
  end
  
  def search(t, brk, robots, resources, {orec, clayc, obsidianc, geodec}=specs, mem, [nxt|nxts]) do

    all = []
    
    {all, brk, mem} = if( afford(orec, resources) and !afford(geodec, resources) and next(nxt,:ore) ) do
      {{max, path}, mem} = dynamic(t-1, brk, build(:ore, robots), collect(robots, orec, resources), specs, mem, nxts)
      {[{max, [:ore|path]}|all], max(max,brk), mem}
    else
      {all, brk, mem}
    end
    {all, brk, mem} = if( afford(clayc, resources) and !afford(geodec, resources) and next(nxt,:clay)) do
      {{max,path}, mem} = dynamic(t-1, brk, build(:clay, robots), collect(robots, clayc, resources), specs, mem, nxts)
      {[{max, [:clay|path]}|all], max(max,brk), mem}
    else
      {all, brk, mem}
    end
    {all,brk,mem} = if( afford(obsidianc, resources) and  next(nxt,:obsidian)) do
      {{max,path}, mem} = dynamic(t-1, brk, build(:obsidian, robots), collect(robots, obsidianc, resources), specs, mem, nxts)
      {[{max,[:obsidian|path]}|all], max(max,brk), mem}
    else
      {all, brk, mem}
    end
    {all,brk,mem} = if( afford(geodec, resources) and next(nxt,:geode)) do
      {{max,path}, mem} = dynamic(t-1, brk, build(:geode, robots), collect(robots, geodec, resources), specs, mem, nxts)
      {[{max, [:geode|path]}|all], max(max,brk), mem}
    else
      {all, brk, mem}
    end
    {all, _, mem} = if( !afford(geodec, resources) and next(nxt,:na) ) do
      {{max,path}, mem} = dynamic(t-1, brk, robots, collect(robots, resources), specs, mem, nxts)
      {[{max, [:na|path]}|all], max(max,brk), mem}
    else
      {all, brk, mem}
    end
    if (all == []) do
      :io.format("\n\n t = ~w nxt = ~w  , nxts = ~w resources = ~w  specs = ~w\n", [t, nxt, nxts, resources, specs])
      throw(:error)
    else
      {Enum.max(all, fn({x,_},{y,_}) -> x > y end), mem}
    end
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
  
  def spend({a0, b0, c0}, {ar,br,cr,dr}) do
    {ar-a0, br-b0, cr-c0, dr}
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
  
  def input() do
    File.stream!("day19.csv")
  end

  def sample() do
    ["Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.",
     "Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian."]
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