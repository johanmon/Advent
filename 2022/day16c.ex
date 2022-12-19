defmodule Day16c do

  def task_b(t) do
    start = :AA
    graph = Day16.sample(start)
    ## graph = Day16.input(start)
    valves = Enum.map(graph, fn({valve,_}) -> valve end)

    k = length(valves)
    floyd_warshall(k, map, valves, Map.new())
  end

  def floyd_warshall(0, _graph, _valves, distances) do
    distances
  end
  def floyd_warshall(k, graph, valves, distances) do
    
  end  
  
    
  
    
end
