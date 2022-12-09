defmodule Day9 do

  ## Day 9 raher tricky to get the tail to follow the head. Fir the
  ## first solution the tail was siply a position. In the second task
  ## the tail was a list of positons and the update/3 function only
  ## had one clause.
  ##
  ## A squence of moves (U 5) is conputed as a sequence of on step
  ## moves. I don't think there is any advantage of trying to do
  ## several moves in one go.
  ##
  ## The follow/2 function had to be updated for the second
  ## solution. All of a sudden we coudl have a knot being (+2,+2) from
  ## the next knot. 
  
  def input() do
    File.stream!("day9.csv") |>
      Stream.map(fn(r) ->
	[dir,n|_] = String.split(r)
	{n,_} = Integer.parse(n)
	dir = String.to_atom(dir)
	{dir, n}
      end) 
  end

  def test() do
    [R: 5,
     U: 8,
     L: 8,
     D: 3,
     R: 17,
     D: 10,
     L: 25,
     U: 20]
  end
  

  def day9a() do
    {_, _, trail} = input() |>
      Enum.reduce({{0,0},[{0,0}], %{}}, fn(move, {head,tail,trail}) -> update(move, head, tail , trail) end)
    length(Map.keys(trail))
  end

  def day9b() do
    {_head, _tail, trail} = input() |>
      Enum.reduce({{0,0},[{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0}], %{}}, fn(move, {head,tail,trail}) -> update(move, head, tail , trail) end)
    length(Map.keys(trail))
  end

  def update({:L,n}, head, tail, trail) do
    Enum.reduce(1..n, {head, tail, trail}, fn(_,{{hr,hc},tail,trail}) -> update({hr-1,hc}, tail, trail) end)
  end
  def update({:R,n}, head, tail, trail) do
    Enum.reduce(1..n, {head, tail, trail}, fn(_,{{hr,hc},tail,trail}) -> update({hr+1,hc}, tail, trail) end)
  end
  def update({:D,n}, head, tail, trail) do
    Enum.reduce(1..n, {head, tail, trail}, fn(_,{{hr,hc},tail,trail}) -> update({hr,hc-1}, tail, trail) end)
  end  
  def update({:U,n}, head, tail, trail) do
    Enum.reduce(1..n, {head, tail, trail}, fn(_,{{hr,hc},tail,trail}) -> update({hr,hc+1}, tail, trail) end)
  end



  def update(head, [last], trail) do 
    tail = follow(head, last)
    trail = Map.put(trail, tail, 1)
    {head, [tail], trail}
  end
  def update(head, [nxt|tail], trail) do
    nxt = follow(head,nxt)
    {_, tail, trail} = update(nxt, tail, trail)
    {head, [nxt|tail], trail}
  end

  def follow({hr,hc}, {tr,tc}) do
    cond do
      (hr == tr-2) ->
	cond do 
	  (hc == tc) ->
	    {tr-1,tc}
	  (hc == tc+1) or (hc == tc+2) ->
	    {tr-1,tc+1}
	  (hc == tc-1) or (hc == tc-2) ->
	    {tr-1,tc-1}
	  true ->
	    {tr,tc}
	end
      (hr == tr+2) ->
	cond do 
	  (hc == tc) ->
	    {tr+1,tc}
	  (hc == tc+1) or (hc == tc+2) ->
	    {tr+1,tc+1}
	  (hc == tc-1) or (hc == tc-2)->
	    {tr+1,tc-1}
	  true ->
	    {tr,tc}
	end
      (hc == tc+2) ->
	cond do 
	  (hr == tr) ->
	    {tr,tc+1}
	  (hr == tr+1) or (hr == tr+2)->
	    {tr+1,tc+1}
	  (hr == tr-1) or (hr == tr-2)->
	    {tr-1,tc+1}
	  true ->
	    {tr,tc}
	end
      (hc == tc-2) ->
	cond do 
	  (hr == tr) ->
	    {tr,tc-1}
          (hr == tr+1) or (hr == tr+2) ->
	    {tr+1,tc-1}
          (hr == tr-1) or (hr == tr-2) ->
	    {tr-1,tc-1}
	  true ->
	    {tr,tc}
	end
      true ->
	{tr,tc}
    end
  end

end
