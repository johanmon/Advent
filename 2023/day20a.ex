defmodule Day20a do

  ##  The firs task was tricky enough but would be easier if one read
  ##  the instructions "including the pulses sent by the button
  ##  itself" .... arghhh! A queue was used to keep track of the
  ##  signals so no problems there.
  ##
  
  def test() do
    String.split(another(), "\n") |>
      Enum.reduce(%{}, fn(row, acc) -> parser(row, acc) end) |>
      connect() |>
      press(0, 0, 1000)
  end

  def task() do
    File.stream!("day20.csv") |>
      Enum.reduce(%{}, fn(row, acc) -> parser(row, acc) end) |>
      connect()  |>
      press(0, 0, 1000) 
  end


  ##  This is the press function

  
  def press(_modules, high, low, 0) do
    {high, low}
  end
  def press(modules, high, low, n) do
    low = low + 1
    {:br, dst} = Map.get(modules, :broadcaster)
    {queue, high, low} = signals(:broadcaster, dst, false, Queue.new(), high, low)
    {high, low, modules} = flow(queue, high, low, modules)
    press(modules, high, low, n-1)
  end

  def flow(queue, high, low, modules) do
    case Queue.dequeue(queue) do
      :nil ->
	{high, low, modules}
      {{from, to, pulse}, queue} ->
	case Map.get(modules, to) do
	  :nil ->
	    flow(queue, high, low, modules)
	  {:br, dst} ->
	    {queue, high, low} = signals(to, dst, pulse, queue, high, low)
	    flow(queue, high, low, modules)	
	  {:ff, on, dst} ->
	    if (pulse) do   #  high is true, signal ignored
	      flow(queue, high, low, modules)
	    else
	      modules = Map.update(modules, to, :nil, fn({:ff, on, dst}) -> {:ff, toggle(on), dst} end)
	      {queue, high, low} = signals(to, dst, toggle(on), queue, high, low)
	      flow(queue, high, low, modules)
	    end
	  {:conj, recv, dst} ->
	    recv = List.keyreplace(recv, from, 0, {from, pulse})
	    modules = Map.update(modules, to, :nil, fn({:conj, _, dst}) -> {:conj, recv, dst} end)
	    pulse = toggle(Enum.all?(recv, fn({_, high}) -> high end))
	    {queue, high, low} = signals(to, dst, pulse, queue, high, low) 
	    flow(queue, high, low, modules)
	end
    end
  end
  
  ## Some helper functions 

  def toggle(on) do not on end
  
  def signals(to, dst, pulse, queue, high, low) do
    signals = Enum.map(dst, fn(name) -> {to, name, pulse} end)
    n = length(signals) 
    queue = Enum.reduce(signals, queue, fn(signal, queue) -> Queue.enqueue(signal, queue) end)
    if pulse do
      {queue, high+n, low}
    else
      {queue, high, low+n}
    end
  end
  

  ## This is where we connect the graph, the :conj modules need to
  ## know from where the signals are comming.
  
  def connect(modules) do
    Enum.flat_map(modules, fn({name, button}) -> 
      if type(button) == :conj do
	[name]
      else
	[]
      end
    end) |>
      Enum.reduce(modules, fn(conj, acc) ->
	Enum.reduce(acc, acc, fn({name, button}, acc) ->
	  if Enum.member?(dest(button),  conj) do
	    Map.update!(acc, conj, fn({:conj, recv, dest}) -> {:conj, [{name, false}|recv], dest} end)
	  else
	    acc
	  end
	end)
      end)
    
  end


  def dest({:br, dest}) do dest end
  def dest({:ff, _, dest}) do dest end
  def dest({:conj, _, dest}) do dest end
  
  def type({:br,_}) do :br end
  def type({:ff, _, _}) do :ff end
  def type({:conj, _, _}) do :conj end

  ## The parser, add all modules to the map of modules

  def parser(row, modules) do
    [module, dest] =  String.split(row, "->")
    case String.trim(module) do
      "broadcaster" ->
	dest = String.split(dest, ",")
	dest = Enum.map(dest, &String.trim/1)
	dest = Enum.map(dest, &String.to_atom/1)
	Map.put(modules, :broadcaster, {:br, dest})
      <<?%, node::binary>> ->
	name = String.to_atom(String.trim(node))
	dest = String.split(dest, ",")
	dest = Enum.map(dest, &String.trim/1)
	dest = Enum.map(dest, &String.to_atom/1)
	Map.put(modules, name, {:ff, false, dest})
      <<?&, node::binary>> ->
	name = String.to_atom(node)
	dest = String.split(dest, ",")
	dest = Enum.map(dest, &String.trim/1)
	dest = Enum.map(dest, &String.to_atom/1)
	Map.put(modules, name, {:conj, [], dest})
    end
  end


  def another() do
"broadcaster -> a
%a -> inv, con
&inv -> b
%b -> con
&con -> output"
  end
  

  
  def sample() do
"broadcaster -> a, b, c
%a -> b
%b -> c
%c -> inv
&inv -> a"
  end
  


end
