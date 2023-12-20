defmodule Day20b do


  ##  The second problem is .... huge. It sounds doable since pushing
  ##  the button a thousand times only takes 20 ms. How many times do
  ##  we have to press? .... many!
  ##
  ##  There are now obvious things we can do to cut down the
  ##  complexity. My first idea was to combine nodes in the graph,
  ##  there were many nodes that only had one in going signal and then
  ##  they could of course be merged with the sender. This would
  ##  improve the situation but the complexity would be the same. 
  ##  
  ##  If no smart algorithm is found we need to look more carefully at
  ##  what the graph looks like. I even started to build a LateX file
  ##  that would print the graph but you don't come long before you see
  ##  something.
  ##
  ##  When looking at the graph you see a pattern; the broadcast
  ##  module will send pulses to four nodes (db, hd, cm, xf) and these
  ##  four nodes form similar graphs. They all consist of a sequence
  ##  of flip-flops that are connected in a chain. All of the
  ##  flip-flops report to the next node in the sequence and some also
  ##  report to a common (for the sequence) conjunction. The
  ##  conjunction in turn sends a signal to some of the nodes in the
  ##  sequence ..... this is a shift register with feedback. 
  ##
  ##  Each sequence starting in: db, hd, cm and xf, are shift
  ##  registers with different feedback. The conjunction of the
  ##  register also sends a signal to a inverter that then sends the
  ##  signal to a common conjunction of all registers, when it
  ##  triggers it will send a low pulse to rx and we are done.
  ##
  ##  Solution, find the description of the registers, find their loop
  ##  and then figure out when they will all send a high pulse to the
  ##  inverter triggering the common conjunction.
  ## 
  ##  These are the four sequences (% report back to memory):
  ##
  ##  [:db, %ml, :bn, :hk, :rs, :hh, %rg, :hr, :kf, %xx, :ff, %ql]
  ##  [%hd, :zl, %qn, :fn, %hn, :tt, :bd, :fd, %hm, %fq, %zk, %sf]
  ##  [%cm, :fh, %jj, :lp, :cz, %nb, %dr, :qc, %tf, :xl, :gq, %lc]
  ##  [:xf, :mb, :bq, %tj, %qd, :dg, :vm, :gm, :qs, %jf, %dn, %rb]
  ##
  ##
  ##  These are the inverters:
  ##
  ##    [:mr, :gl, :bb, :kk]
  ##  
  ##  These are the four memories [feedback to sequence] :
  ##
  ##    nl: [:db, :hr, :hh, :hk, :rs, :bn] -> :mr -> :qt -> :rx
  ##    jx: [:fn, :bd, :tt, :zl, :hd]      -> :gl ->  | 
  ##    vj: [:qc, :cm]                     -> :bb ->  |
  ##    cr: [:dg, :bq, :xf, :gm]           -> :kk ->  |
  ##
  ## 
  ## Hmm, can we simply run the model and check each sequence of
  ## signals to the inverters?
  ##
  ##     bb - cycle of 3967
  ##     gl - cycle of 3989
  ##     kk - cycle of 3931
  ##     mr - cycle of 3907
  ##
  ##  That should do it, multiply the cycles and we're done :-)
  ##
  ##  ... we can do this since thery are all primes and do not share
  ##  any factor.
  
  def task() do 
    :io.format("Look at the sequence of triggered inverters.~n")

    File.stream!("day20.csv") |>
      Enum.reduce(%{}, fn(row, acc) -> parser(row, acc) end) |>
      connect()  |>
      press(0, 0, 10000)
  end


  ##  This is all to better understand what the graph looks like.
  
  def graph_b() do
    modules = File.stream!("day20.csv") |>
      Enum.reduce(%{}, fn(row, acc) -> parser(row, acc) end) |>
      connect()
    
    {:br, sequences} = Map.get(modules, :broadcaster)
    [collector] = Enum.flat_map(modules, fn({name, module}) ->
      case module do
	{:conj, _, [:rx]} -> [name]
	_ ->  []
      end
    end)
    inverters =  Enum.flat_map(modules, fn({name, module}) ->
      case module do
	{:conj, _, dest} ->
	  if (Enum.member?(dest, collector)) do
	    [name]
	  else
	    []
	  end
	_ ->
	  []
      end
    end)
    memories =  Enum.flat_map(modules, fn({name, module}) ->
      case module do
	{:conj, _, dest} ->
	  if Enum.any?(dest, fn(dst) -> Enum.member?(inverters, dst) end) do
	    [name]
	  else
	    []
	  end
	_ ->
	  []
      end
    end)
    sequences = sequences(sequences, memories, modules)
    memories = Enum.flat_map(memories, fn(name) ->
      case Map.get(modules, name) do
	{:conj, _, dst} -> [{name, dst}]
      end
    end)
    {sequences, memories, inverters, collector}
  end

  def sequences(start, mem, modules) do
    Enum.map(start, fn(first) ->
      trail(first, mem, modules)
    end)
  end

  def trail(node, mem, modules) do
    case Map.get(modules, node) do 
      {:ff, _, [d]} ->
	case trail(d, mem, modules) do
	  [] -> [{:r, node}]
	  rest -> [node| rest]
	end
      {:ff, _, [a,b]} ->
	case trail(a, mem, modules) do
	  [] -> [{:r, node} | trail(b, mem, modules)]
	  rest -> [node | rest]
	end
      _ ->
	[]
    end
  end
  

  ##  This is the original press function, modified to write out the
  ##  press number of the inverters (there are only four inverters
  ##  that we are interested in.
  
  def press(_modules, high, low, 0) do
    {high, low}
  end
  def press(modules, high, low, n) do
    low = low + 1
    {:br, dst} = Map.get(modules, :broadcaster)
    {queue, high, low} = signals(:broadcaster, dst, false, Queue.new(), high, low)
    {high, low, modules} = flow(queue, high, low, modules, (10001 - n))
    press(modules, high, low, n-1)
  end

  def flow(queue, high, low, modules, n) do
    case Queue.dequeue(queue) do
      :nil ->
	{high, low, modules}
      {{from, to, pulse}, queue} ->
	case Map.get(modules, to) do
	  :nil ->
	    flow(queue, high, low, modules, n)
	  {:br, dst} ->
	    {queue, high, low} = signals(to, dst, pulse, queue, high, low)
	    flow(queue, high, low, modules, n)	
	  {:ff, on, dst} ->
	    if (pulse) do   #  high is true, signal ignored
	      flow(queue, high, low, modules, n)
	    else
	      modules = Map.update(modules, to, :nil, fn({:ff, on, dst}) -> {:ff, toggle(on), dst} end)
	      {queue, high, low} = signals(to, dst, toggle(on), queue, high, low)
	      flow(queue, high, low, modules, n)
	    end
	    ## Special for inverters 
	  {:conj, [{from,_}], [d]} ->
	    if !(pulse)  do 
  	      :io.format("~w: ~w~n", [n, to])
	    end
	    modules = Map.put(modules, to, {:conj, [{from, pulse}], [d]})
	    {queue, high, low} = signals(to, [d], toggle(pulse), queue, high, low)
	    flow(queue, high, low, modules, n)	    
	    
	  {:conj, recv, dst} ->
	    recv = List.keyreplace(recv, from, 0, {from, pulse})
	    modules = Map.update(modules, to, :nil, fn({:conj, _, dst}) -> {:conj, recv, dst} end)
	    pulse = toggle(Enum.all?(recv, fn({_, high}) -> high end))
	    {queue, high, low} = signals(to, dst, pulse, queue, high, low) 
	    flow(queue, high, low, modules, n)
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
