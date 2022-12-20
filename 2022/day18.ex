defmodule Day18 do

  ## Day 18 - part one was ok. Instead of using the simple way of
  ## keeping one map of all pixels {x,y,z} I organized the map in
  ## three maps. One map view the scene in z-direction, another in x-
  ## and the third in y-direction. A map then held one map for each
  ## column and each column held a list of segments of pixels. Once
  ## these maps are filled with all pixels its easy to dtermine the
  ## open sides.
  ##
  ## The second task took some time since it involved a lot of
  ## debugging :-0 The algorithm was as follows:
  ##
  ##    create the tree maps as before
  ##    determine the bounding box and
  ##       creat a new map to hold water pixels
  ##    fill auter sides with water 
  ##    perculate all water pixels
  ##    as before detmine open side but now take water into account

  def task_a() do

    seq = input()

    x = Map.new()
    y = Map.new()
    z = Map.new()
    {mx, my, mz} = Enum.reduce(seq, {x,y,z}, fn({x,y,z}, {mx,my,mz}) ->
      mx = insert(mx, x, {y,z})
      my = insert(my, y, {z,x})
      mz = insert(mz, z, {x,y})
      {mx,my,mz}
    end)
    
    [nx,ny,nz] = Enum.map([mx,my,mz], fn(mx) -> 
      Enum.reduce(mx, 0, fn({_,my}, a) ->
	Enum.reduce(my, a, fn({_,zs}, a) ->
	  Enum.reduce(zs, a, fn(_,a) -> a + 2 end)
	end)
      end)
    end)
    nx+ny+nz
  end


  def task_b() do

    seq = input()

    x = Map.new()
    y = Map.new()
    z = Map.new()
    {mx, my, mz} = Enum.reduce(seq, {x,y,z}, fn({x,y,z}, {mx,my,mz}) ->
      mx = insert(mx, x, {y,z})
      my = insert(my, y, {z,x})
      mz = insert(mz, z, {x,y})
      {mx,my,mz}
    end)

    xs = Enum.sort(Map.keys(mx))
    ys = Enum.sort(Map.keys(my))
    zs = Enum.sort(Map.keys(mz))

    {{:ok, x0},{:ok, xn}} = {Enum.fetch(xs,0), Enum.fetch(xs,-1)}
    {{:ok, y0},{:ok, yn}} = {Enum.fetch(ys,0), Enum.fetch(ys,-1)}
    {{:ok, z0},{:ok, zn}} = {Enum.fetch(zs,0), Enum.fetch(zs,-1)}

    water =  MapSet.new()

    water = Enum.reduce(x0..xn, water, fn(x,water) ->
      Enum.reduce(y0..yn, water, fn(y, water) ->
	water = if (!filled(mx, x, y, z0)) do
	    ## :io.format(" adding ~w\n", [{x,y,z0}])
	    MapSet.put(water, {x,y,z0})
	  else
	    water
	  end
	if  (!filled(mx, x, y, zn)) do
	    ## :io.format(" adding ~w\n", [{x,y,zn}])
	    MapSet.put(water, {x,y,zn})
	else
	  water
	end
      end)
    end)

    water = Enum.reduce(y0..yn, water, fn(y,water) ->
      Enum.reduce(z0..zn, water, fn(z, water) ->
	water = if (!filled(mx, x0, y, z)) do
	    ## :io.format(" adding ~w\n", [{x0,y,z}])
	    MapSet.put(water, {x0,y,z})
	  else
	    water
	  end
	if  (!filled(mx, xn, y, z)) do
	    ## :io.format(" adding ~w\n", [{xn,y,z}])
	    MapSet.put(water, {xn,y,z})
	else
	  water
	end
      end)
    end)    

    water = Enum.reduce(z0..zn, water, fn(z,water) ->
      Enum.reduce(x0..xn, water, fn(x, water) ->
	water = if (!filled(mx, x, y0, z)) do
	    ## :io.format(" adding ~w\n", [{x,y0,z}])
	    MapSet.put(water, {x,y0,z})
	  else
	    water
	  end
	if  (!filled(mx, x, yn, z)) do
	    ## :io.format(" adding ~w\n", [{x,yn,z}])
	    MapSet.put(water, {x,yn,z})
	else
	  water
	end
      end)
    end)    

    ## perculate 

    continue =  fn(x, y, z, water) ->
      ((x0 < x and x < xn) and (y0 < y and y < yn) and (z0 < z and z < zn) and !MapSet.member?(water, {x,y,z}) and !filled(mx, x, y ,z))
    end

    water = Enum.reduce(MapSet.to_list(water), water, fn(pos, water) ->
      perculate([pos], continue, water)
    end)

    nx =  Enum.reduce(mx, 0, fn({x,my}, a) ->
	Enum.reduce(my, a, fn({y,zs}, a) ->
	  a + free(zs, fn(z) -> z < z0 or z > zn or MapSet.member?(water, {x,y,z}) end, 0)
	end)
      end)

    ny =  Enum.reduce(my, 0, fn({y,mz}, a) ->
	Enum.reduce(mz, a, fn({z,xs}, a) ->
	  a + free(xs, fn(x) -> x < x0 or x > xn or MapSet.member?(water, {x,y,z}) end, 0)
	end)
    end)

    nz =  Enum.reduce(mz, 0, fn({z,mx}, a) ->
	Enum.reduce(mx, a, fn({x,ys}, a) ->
	  a + free(ys, fn(y) -> y < y0 or y > yn or MapSet.member?(water, {x,y,z}) end, 0)
	end)
      end)    

    {nx,ny,nz}
  end

  def free([], _water, a) do a end
  def free([{z0,z1}|rest], water, a) do
    a = if water.(z0-1) do
      a+1
    else
      a
    end
    a = if water.(z1+1) do
      a+1
    else
      a
    end
    free(rest,water, a)
  end


  def perculate([], _continue, water) do water end
  def perculate([{x,y,z}|rest], continue, water) do
    {cont, water} = Enum.reduce([{x+1,y,z},{x-1,y,z},{x,y+1,z},{x,y-1,z},{x,y,z+1},{x,y,z-1}], {[],water}, fn({x,y,z}, {cont,water}) ->
      if (continue.(x,y,z, water)) do
	{[{x,y,z}|cont], MapSet.put(water, {x,y,z})}
      else
	{cont, water}
      end
    end)
    perculate(cont ++ rest, continue, water)
  end

  def filled(mx, x, y,z) do
    case Map.get(mx, x) do
      nil -> false
      my -> case Map.get(my, y) do
	      nil -> false
	      zs -> filled(zs, z)
	    end
    end
  end

  def count([]) do 0 end
  def count([{x0,xn}|rest]) do (xn-x0+1) + count(rest) end
  
  def filled([],_) do false end
  def filled([{z0,_}|_], z) when z < z0 do false end
  def filled([{z0,z1}|_], z) when z0 <= z and z <= z1 do true end  
  def filled([_|rest], z) do filled(rest, z) end

  
  def insert(mx, x, {y,z}) do
    Map.update(mx, x, 	Map.new([{y, [{z,z}]}]), fn(yz) ->
      Map.update(yz, y, [{z,z}], fn(zs) -> update(zs, z) end)
    end)
  end

  
  def update([], z) do [{z,z}] end
  def update([{z0,z1}|rest], z) when z == (z0-1) do [{z,z1}|rest] end  
  def update([{z0,_}|_]=zs, z) when z < z0 do [{z,z}|zs] end
  def update([{z0,z1}|_]=zs, z) when z0 <= z and z <= z1 do zs end  
  def update([{z0,z1},{z2,z3}|rest], z) when z == (z1+1) and z == (z2-1) do [{z0,z3}|rest] end
  def update([{z0,z1}|rest], z) when z == (z1+1) do [{z0,z}|rest] end  
  def update([zs|rest], z) do  [zs|update(rest,z)] end  
      

  def input() do
    File.stream!("day18.csv") |>
      Enum.map(fn(r) ->
	String.split(String.trim(r), ",") |>
	  Enum.map(fn(n) ->
	    {n, _} = Integer.parse(n)
	    n
	  end)
      end) |>
      Enum.map(fn(x) -> List.to_tuple(x) end)
  end


  def sample() do
    [ {2,2,2},
      {1,2,2},
      {3,2,2},
      {2,1,2},
      {2,3,2},
      {2,2,1},
      {2,2,3},
      {2,2,4},
      {2,2,6},
      {1,2,5},
      {3,2,5},
      {2,1,5},
      {2,3,5}]
  end
  

end
