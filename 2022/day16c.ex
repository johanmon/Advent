defmodule Day16c do


  ## Day 16, this took me some time :-) The trategy is to partition
  ## the set of valves into two sets. Since you and the elefant can
  ## not open the same valves the set of vlaves need to be partitioned
  ## in two.
  ##
  ## The second step is to take a set of valves and for each
  ## permutation calculate the total flow after 26 min. Given a
  ## partition we can thus caclulate teh maximum combined flow from
  ## the two sets.
  ##
  ## All good and Dandy but the number of permutations of sets of 14
  ## valves is quite large (... large!) so we need to take a wild
  ## guess. It is more likely that the total maximum flow is reached
  ## if you and the elefant open more or less the same number of
  ## valves so we begin to examine the partitions were either has
  ## eight valves (15 valves in the set). 
  ##
  ## This still takes some time but if we print the best sofar we can
  ## give it a try :-)

  ## sequences for the sample that maximise flow
  ##
  ## [AA: 0,  DD: 20, BB: 13, JJ: 21, HH: 22, EE: 3, CC: 2]  flow(t) = 1651
  ## {[AA: 0, JJ: 21, BB: 13, CC: 2], [AA: 0, DD: 20, HH: 22, EE: 3]}


  def task_b() do
    start = :AA
    #graph = Day16.sample(start)
    graph = Day16.input(start)

    dist = shortest(graph)

    valves = Enum.map(graph, fn({v, {d, _}}) -> {v, d} end)

    start = {:AA, 0}
    
    valves = List.delete(valves, start)

    :io.format("number of valves : ~w\n", [length(valves)])
    
    partitions = partition_first(valves)

    :io.format("number of partitions : ~w\n", [length(partitions)])    

    k = 8
    #k = 3
    selected = Enum.filter(partitions, fn({a,b}) -> (length(a) == k) || (length(b) == k) end)

    :io.format("number of selected : ~w\n", [length(selected)])
    
    max = Enum.reduce(selected, 0, fn({a,b}, max) ->
      {best_a, _seq_a} = best(26, start, a, dist)
      {best_b, _seq_b} = best(26, start, b, dist)
      #:io.format("try: ~w  ~w \n", [a, b])
      #:io.format("~w  ~w: ~w  ~w \n", [max, best_a+best_b, seq_a, seq_b])
      :io.format("(~w  ~w), ", [max, best_a+best_b])
      max(best_a + best_b, max)
    end)
    :io.format("\n selected length: ~w  max ~w \n", [k, max])

    k = 9
    #k = 4
    
    selected = Enum.filter(partitions, fn({a,b}) -> (length(a) == k) || (length(b) == k) end)

    :io.format("number of selected : ~w\n", [length(selected)])
    
    max = Enum.reduce(selected, 0, fn({a,b}, max) ->
      {best_a, _seq_a} = best(26, start, a, dist)
      {best_b, _seq_b} = best(26, start, b, dist)      
      max(best_a + best_b, max)
    end)
    :io.format("\n selected length: ~w  max ~w \n", [k, max])

  end

  def best(t, start, seq, dist) do
    Enum.reduce(permute(seq), {0,:na}, fn(seq, {max,_}=sofar) ->
      flow = flow(t, [start|seq], dist)
      if  flow > max do
	{flow, seq}
      else
	sofar
      end
    end)
  end

  
  def permute([a]) do [[a]] end
  def permute(seq) do
    Enum.reduce(seq, [], fn(x, all) ->
      rest = List.delete(seq, x)
      permuted = permute(rest)
      Enum.map(permuted, fn(rest) -> [x|rest] end) ++ all
    end)
  end

  ## We only need to try half of the partitions since the rest are
  ## mirror images.
  
  def partition_first([]) do [{[], []}]  end  
  def partition_first([v|rest])  do
    part = partition(rest)
    partition_first(part, v)
  end

  def partition_first([], _) do [] end
  def partition_first([{a, b}|rest], v) do
    [{[v|a],b} | partition_first(rest, v)]
  end    

  def partition([]) do [{[], []}]  end  
  def partition([v|rest])  do
    part = partition(rest)
    partition(part, v)
  end
  
  def partition([], _) do [] end
  def partition([{a, b}|rest], v) do
    [{[v|a],b}, {a,[v|b]} | partition(rest, v)]
  end  


  ## The total flow is quite easy to calculate given the table with
  ## shortest distance between any two valves. 
  
  def flow(t, valves, dist) do flow(t, valves, 0, dist, 0) end
    
  def flow(t, [_], rate, _dist, total) do
    ##:io.format(" time = ~w  rate = ~w\n", [t, rate])    
    total + (rate * t)
  end
  def flow(t, [{id1, _} | [{id2, r}|_]=rest], rate, dist, total) do
    ##:io.format(" time = ~w  rate = ~w\n", [t, rate])
    ## move to and open valve id2 if possible
    case Map.get(dist, {id1,id2}) do
      d when (d + 1) <= t->
	flow( t-(d+1), rest, rate+r, dist, total + rate*(d+1))
      _ ->
	total + (rate * t)
    end
  end


  def shortest(graph) do 
    valves = Map.keys(graph)

    k = length(valves)
    dist = Enum.reduce(valves, Map.new(), fn(valve, acc) ->
      Map.put(acc, {valve,valve}, 0)
    end)
      
    dist = Enum.reduce(valves, dist, fn(valve, acc) ->
      {_, direct} = Map.get(graph, valve)
      Enum.reduce(direct, acc, fn({to,dst}, acc) ->
	Map.put(acc, {valve, to}, dst)
      end)
    end)
    floyd_warshall(k, valves, dist)
  end
    
	
  def floyd_warshall(0, _valves, dists) do
    dists
  end
  def floyd_warshall(k, valves, dists) do
    dists = Enum.reduce(valves, dists, fn(from, dst) ->
      Enum.reduce(valves, dst, fn(to, dst) ->
	min = Enum.reduce(valves, Map.get(dists, {from, to}),
	fn(nxt, min) ->
	  case Map.get(dst, {from,nxt}) do
	    nil ->
	      min
	    d1 ->
	      case Map.get(dst, {nxt, to}) do
		nil ->
		  min
		d2 ->
		  min(min,d1+d2)
	      end
	  end
	end)

	if (min != nil) do
	  Map.put(dst, {from, to}, min)
	else
	  dst
	end
      end)
    end)
    floyd_warshall(k-1, valves, dists)
  end
    
  
    
end
