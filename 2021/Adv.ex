defmodule Adv do

  def day1a() do
    count = fn (x, {prev, sum})  ->
      if (x > prev) do
	{x, sum+1}
      else
	{x, sum}
      end
    end
    {_, answer} = File.stream!("day1.csv") |>
      Stream.map( fn (r) -> {n, _} = Integer.parse(r); n end) |>
      Enum.reduce({:inf, 0}, count)
    answer
  end

  def day1b() do
    count = fn (x, {p1, p2, p3, sum}) ->
        if add(x, add(p1, p2)) > add(p1, add(p2,p3)) do
          {x,p1,p2, sum+1}
        else
          {x,p1,p2, sum}
        end
    end

   {_,_,_, answer} =  File.stream!("day1.csv") |>
      Stream.map( fn (r) -> {n, _} = Integer.parse(r); n end) |>
      Enum.reduce({:inf, :inf, :inf, 0}, count)
   answer
  end

  defp add(_, :inf) do :inf end
  defp add(:inf, _) do :inf end
  defp add(x, y) do x+y end  

  ##==================================================================

  
  def day2a() do
    count = fn ({dir, val}, {depth, dist}) ->
      case dir do
	"down" ->	
	  {depth+val, dist}
	"up" ->
	  {depth-val, dist}
	"forward" ->
	  {depth, dist+val}
      end
    end
    File.stream!("day2.csv") |>
      Stream.map( fn (r) -> [dir, nr] = String.split(r); {val, _} = Integer.parse(nr); {dir, val} end) |>
      Enum.reduce({0,0}, count)
  end

  
  def day2b() do 
    count = fn ({dir, val}, {depth, dist, aim}) ->
      case dir do
	"down" ->	
	  {depth, dist, aim+val}
	"up" ->
	  {depth, dist, aim-val}
	"forward" ->
	  {depth+(aim*val), dist+val, aim}
      end
    end

    File.stream!("day2.csv") |>
      Stream.map( fn (r) -> [dir, nr] = String.split(r); {val, _} = Integer.parse(nr); {dir, val} end) |>
      Enum.reduce({0,0,0}, count)
  end   

  ##==================================================================

  def day3a() do

    {l, seq} = File.stream!("day3.csv") |>
      Enum.map( &chars_to_bin/1 ) |>
      Enum.reduce({0,[]}, fn(x, {l,s}) -> {l+1, add_bin(x,s)} end)

    gamma = rate(seq, l, &</2) 

    epsilon = rate(seq, l, &>=/2) 
    
    {bin_to_int(gamma), bin_to_int(epsilon)}
  end

  def  rate(ks, l, op) do
    Enum.map(ks, fn x -> if op.(x,(l-x)), do: 0, else: 1  end)
  end

  ## We need this to parse the line as a list of ones and zeros i.e. [1,0,1,1] 

  def chars_to_bin(<<_>>) do [] end
  def chars_to_bin(<<?0, rest::binary>>) do [0| chars_to_bin(rest)] end
  def chars_to_bin(<<?1, rest::binary>>) do [1| chars_to_bin(rest)] end

  ## adding two binary lists 
  def add_bin(x, []) do x end
  def add_bin(x,a) do
    Enum.zip_with(a, x, fn (i, j) -> i + j  end)
  end
  
  ## convert to an integer 
  def bin_to_int(bin) do
    List.foldl(bin, 0, fn (x, a) -> a*2 + x end)
  end


  def day3b() do
    seq = File.stream!("day3.csv") |>
      Enum.map( &chars_to_bin/1 )

    oxygen = rating(seq, &</2)
    scrubber = rating(seq, &>=/2)

    {bin_to_int(oxygen), bin_to_int(scrubber)}
  end

  def rating([done], _) do  done end
  def rating( seq, op) do 
    {k,l} = List.foldl(seq, {0,0}, fn ([b|_], {s,l}) -> {s+b,l+1} end)
    b = if op.(k, l-k) do
      0
    else
      1
    end
    ## Hmm, this is not tail recursive, should we change.
    [b|rating(filter_seq(seq, b), op)]
  end

  def filter_seq([], _) do [] end
  def filter_seq([[b|tail]|rest], b) do [tail|filter_seq(rest,b)] end  
  def filter_seq([_|rest], b) do filter_seq(rest,b) end

  ##==================================================================  

  def day4a() do
    [seq| brds] = String.split( File.read!("day4.csv"), "\n")
    seq = Enum.map(String.split(seq, ","), fn (nr) -> {n,_} = Integer.parse(nr); n end)
    brds = boards(brds)
    play(seq, brds)
  end

  def boards([]) do [] end
  def boards([_,r1,r2,r3,r4,r5|rest]) do
    [r1,r2,r3,r4,r5] = Enum.map([r1,r2,r3,r4,r5], fn (r) -> row(r) end)
    c1 = col(1, r1, r2, r3, r4, r5)
    c2 = col(2, r1, r2, r3, r4, r5)
    c3 = col(3, r1, r2, r3, r4, r5)
    c4 = col(4, r1, r2, r3, r4, r5)
    c5 = col(5, r1, r2, r3, r4, r5)        
    [[r1,r2,r3,r4,r5,c1,c2,c3,c4,c5]| boards(rest)]
  end

  def row(r) do
    Enum.map( String.split(r," ", trim: true), fn (nr) -> {n,_} = Integer.parse(nr); n end)
  end

  def col(1,r1,r2,r3,r4,r5) do
    [hd(r1),hd(r2),hd(r3),hd(r4),hd(r5)]
  end
  def col(c,r1,r2,r3,r4,r5) do
    col(c-1, tl(r1),tl(r2),tl(r3),tl(r4),tl(r5))
  end

  def  bingo(brd) do
    List.foldl(brd, false, fn (x,a) -> (a || [] == x) end)
  end

  # We have a winner if one of the boards is a winner

  def winner([]) do false end
  def winner([br|brds]) do
    if bingo(br) do
      br
    else
      winner(brds)
    end
  end

  # The score is now simply the sum of what is left in the rows (don't
  # count the columns as well since all squares occur twice).

  def score([r1,r2,r3,r4,r5|_], n) do
    List.foldl([r1,r2,r3,r4,r5], 0, fn (r,a) -> Enum.sum(r) + a end) * n
  end

  # So, now it is time to play. Call a number and filter the boards that
  # we have. If we have a winner we stop. 

  def play([], _) do [] end
  def play([n|seq], brds) do
    brds = Enum.map(brds, fn b -> Enum.map(b, fn r -> Enum.reject(r, fn x -> x == n end) end) end)
    win = winner(brds)
    if win do
      score(win, n)
    else
      play(seq,brds)
    end
  end

  def day4b() do
    [seq| brds] = String.split( File.read!("day4.csv"), "\n")
    seq = Enum.map(String.split(seq, ","), fn (nr) -> {n,_} = Integer.parse(nr); n end)
    brds = boards(brds)
    plau(seq, brds, :na)
  end

  def wanner([]) do {[],[]} end
  def wanner([brd|brds]) do
    {w,r} = wanner(brds)
    if bingo(brd) do
      {[brd|w], r}
    else
      {w, [brd|r]}
    end
  end

  def plau([], _, last) do last end
  def plau([n|seq], brds, last) do
    brds = Enum.map(brds, fn b -> Enum.map(b, fn r -> Enum.reject(r, fn x -> x == n end) end) end)
    {win, rest} = wanner(brds)
    case Enum.sort(Enum.map(win, fn (b) -> score(b,n) end), &>/2) do
      [] ->	
	plau(seq, rest, last)
      [last|_] ->
	plau(seq, rest, last)
    end
  end
  
  ##==================================================================

  def day5a() do
    seq = String.split( File.read!("day5.csv"), "\n") |>
      Enum.map(fn r ->
	[from, to] = String.split(r, "-> ")
	[x1,y1] = String.split(from, ",")
	[x2,y2] =  String.split(to, ",")
	{x1,_} = Integer.parse(x1)
	{y1,_} = Integer.parse(y1)
	{x2,_} = Integer.parse(x2)
	{y2,_} = Integer.parse(y2)
	{{x1,y1}, {x2,y2}}
      end) |>
      Enum.filter(fn ({{x1,y1}, {x2,y2}}) -> (x1 == x2) || (y1 == y2) end)
    twos(update(seq, %{}))
  end

  def twos(mtx) do
    List.foldl(Map.values(mtx), 0, fn (xv,a) -> List.foldl(Map.values(xv), a, fn (yv, a) -> if yv >= 2, do: a+1, else: a end) end)
  end

  def update([], mtx) do mtx end
  def update([{{x1,y1}, {x1, y2}}|rest], mtx) do
    mtx =  Map.update(mtx, x1,
      Enum.reduce(y1..y2, %{}, fn(yi, mx) -> Map.put(mx, yi, 1) end),
      fn (mx) ->
	Enum.reduce(y1..y2, mx,
	  fn (yi, my) ->
	    Map.update(my, yi, 1,  fn (n) -> n+1 end)
	  end)
	end)
    update(rest, mtx)
  end
  def update([{{x1,y1}, {x2, y1}}|rest], mtx) do
    mtx = Enum.reduce(x1..x2, mtx, fn (xi, mx) ->
	  Map.update(mx, xi, %{y1 => 1}, fn (my) ->
	    Map.update(my, y1, 1, fn (n) -> n+1 end) end) end)
    update(rest, mtx)
  end

  def day5b() do
    seq = String.split( File.read!("day5.csv"), "\n") |>
      Enum.map(fn r ->
	[from, to] = String.split(r, "-> ")
	[x1,y1] = String.split(from, ",")
	[x2,y2] =  String.split(to, ",")
	{x1,_} = Integer.parse(x1)
	{y1,_} = Integer.parse(y1)
	{x2,_} = Integer.parse(x2)
	{y2,_} = Integer.parse(y2)
	{{x1,y1}, {x2,y2}}
      end)
    twos(updateb(seq, %{}))
  end

  def updateb([], mtx) do mtx end
  def updateb([{{x1,y1}, {x1, y2}}|rest], mtx) do
    mtx =  Map.update(mtx, x1,
      Enum.reduce(y1..y2, %{}, fn(yi, mx) -> Map.put(mx, yi, 1) end),
      fn (mx) ->
	Enum.reduce(y1..y2, mx,
	  fn (yi, my) ->
	    Map.update(my, yi, 1,  fn (n) -> n+1 end)
	  end)
	end)
    updateb(rest, mtx)
  end
  def updateb([{{x1,y1}, {x2, y1}}|rest], mtx) do
    mtx = Enum.reduce(x1..x2, mtx, fn (xi, mx) ->
	  Map.update(mx, xi, %{y1 => 1}, fn (my) ->
	    Map.update(my, y1, 1, fn (n) -> n+1 end) end) end)
    updateb(rest, mtx)
  end
  def updateb([{{x1,y1}, {x2, y2}}|rest], mtx) do
    mtx = List.foldl( Enum.zip(x1..x2, y1..y2), mtx, fn ({xi,yi}, m) ->
      Map.update(m, xi, %{yi => 1}, fn (my) ->
	Map.update(my, yi, 1, fn (n) -> n+1 end) end) end)
    updateb(rest, mtx)
  end

  ##==================================================================


  def day6a() do
    pop =  String.split( File.read!("day6.csv"), ",") |>
      Enum.map(fn (nr) -> {n,_} = Integer.parse(nr); n end) |>
      List.foldl({0,0,0,0,0,0,0,0,0}, fn (n, pop) -> update_elem(pop, n) end)
    Tuple.sum(days(80, pop))
  end

  def update_elem(pop, n) do
    :erlang.setelement(n+1, pop, elem(pop, n)+1)
  end

  def days(0, pop) do pop end
  def days(n, {x0,x1,x2,x3,x4,x5,x6,x7,x8}) do
    days(n-1, {x1,x2,x3,x4,x5,x6,x7+x0,x8,x0})
  end


  def day6b() do
    pop =  String.split( File.read!("day6.csv"), ",") |>
      Enum.map(fn (nr) -> {n,_} = Integer.parse(nr); n end) |>
      List.foldl({0,0,0,0,0,0,0,0,0}, fn (n, pop) -> update_elem(pop, n) end)
    Tuple.sum(days(256, pop))
  end

  ##==================================================================


  def day7a() do
    seq =  String.split( File.read!("day7.csv"), ",") |>
      Enum.map(fn (nr) -> {n,_} = Integer.parse(nr); n end)
    {mi,mx} = List.foldl(seq, {:inf,0}, fn (k,{mi,mx}) -> {min(k,mi),max(k,mx)} end)
    List.foldl( Enum.map(mi..mx, fn (m) -> List.foldl(seq, 0, fn(k, a) -> a + abs(k-m) end) end),
      :inf,
      fn (d,mn) -> min(d,mn) end)
  end


  def day7b() do
    seq =  String.split( File.read!("day7.csv"), ",") |>
      Enum.map(fn (nr) -> {n,_} = Integer.parse(nr); n end)
    {mi,mx} = List.foldl(seq, {:inf,0}, fn (k,{mi,mx}) -> {min(k,mi),max(k,mx)} end)
    List.foldl( Enum.map(mi..mx, fn (m) -> List.foldl(seq, 0, fn(k, a) -> d = abs(k-m); a + trunc((d+1) * (d/2))  end) end),
      :inf,
      fn (d,mn) -> min(d,mn) end)
  end

  ##==================================================================

  def day8a() do
    File.stream!("day8.csv") |>
      Enum.map(fn(row) ->
	[signals, displays] = String.split(String.trim(row,"\n"), " | ")
	signals = String.split(signals, " ")
	 displays = String.split(displays, " ")
	{signals, displays}
      end) |>
      List.foldl({0,0,0,0,0,0,0,0}, fn({_,displ}, count) ->
	List.foldl(displ, count, fn(dis, cnt) -> update_elem(cnt, String.length(dis)) end) end)
  end

  def day8b() do
    File.stream!("day8.csv") |>
      Enum.map(fn(row) ->
	[signals, displays] = String.split(String.trim(row,"\n"), " | ")
	signals = String.split(signals, " ")
	 displays = String.split(displays, " ")
	{signals, displays}
      end) |>
      List.foldl(0, fn({nrs, displ}, sum) -> decode(displ, table(nrs)) + sum end)
  end

  def table(nrs) do
    nrs = Enum.map(nrs, fn(nr) -> code = Enum.sort(String.to_charlist(nr)); {length(code), code} end)

    ## We only need to know what the numbers look like.
    {[{_,one}], rest} =  Enum.split_with(nrs, fn({n,_}) -> n == 2 end)
    {[{_,seven}], rest} = Enum.split_with(rest, fn({n,_}) -> n == 3 end)
    {[{_,four}], rest} = Enum.split_with(rest, fn({n,_}) -> n == 4 end)
    {[{_,eight}], rest} = Enum.split_with(rest, fn({n,_}) -> n == 7 end)

    ## Then there are 0-6-9 and 2-3-5
    {[{_,n1},{_,n2},{_,n3}], [{_,m1},{_,m2},{_,m3}]} = Enum.split_with(rest, fn({n,_}) -> n == 6 end)

    ## 9 is the only one that overlaps 4
    {[nine], zero_six} =  Enum.split_with([n1,n2,n3], fn(nr) -> Enum.all?(four, fn(c) -> Enum.member?(nr,c) end) end)

    ## 0 overlaps 1
    {[zero], [six]} =  Enum.split_with(zero_six, fn(nr) -> Enum.all?(one, fn(c) -> Enum.member?(nr,c) end) end)

    ## 3 overlaps 1
    {[three], [r1,r2]} =  Enum.split_with([m1,m2,m3], fn(nr) -> Enum.all?(one, fn(c) -> Enum.member?(nr,c) end) end)


    #  5 almost overlap 4 (3 out of 4),  2 only overlaps 4 by 2 
    {[two], [five]} =  if length( Enum.filter(r1, fn(c) -> Enum.member?(four,c) end) ) == 3 do
                           {[r2],[r1]}
                       else
                          {[r1],[r2]}
                       end

    [zero, one, two, three, four, five, six, seven, eight, nine]
  end

  def decode(displ, table) do
    displ = Enum.map(displ, fn(ds) -> code = Enum.sort(String.to_charlist(ds));  code  end)

    [d1,d2,d3,d4] =  Enum.map(displ, fn(ds) -> lookup(ds, 0, table) end)
  
    d1*1000 + d2*100 + d3*10 + d4    
  end

  def lookup(ds, n, [ds|_]) do n end
  def lookup(ds, n, [_|rest]) do lookup(ds, n+1, rest) end  



  ##==================================================================

  def day9a() do
    seq = File.stream!("day9.csv") |>
      Enum.map(fn(row) ->   [:inf | depth(row)  ++ [:inf]] end)
    inf = List.duplicate(:inf, length(hd(seq)))
    seq = [ inf | seq ++ [inf]]
    scan(seq, 0) 
  end

  def depth(<<>>) do [] end
  def depth(<<10>>) do [] end  
  def depth(<<c, rest::binary>>) do [c-48|depth(rest)] end  
  
  def scan([_,_], danger) do danger end
  def scan([north, this, south | rest], danger) do
    dgr = scan(north, this, south, 0)
    scan([this, south | rest], danger + dgr)
  end

  def scan([_,_], [_,_], [_,_], danger) do danger end
  def scan(
    [ _, n | rn],
    [ w, t,  e | rt],
    [ _, s | rs],  danger) do 
    d = if (t < n) && (t < s) && (t < w) && (t < e) do
      t + 1
    else
      0
    end
    scan([n|rn], [t,e|rt], [s|rs], danger + d)
  end

  def day9b() do
    {seq,_} = File.stream!("day9.csv") |>
      Enum.map_reduce(1, fn (row, a) -> { [{:na, :inf}|( depth(row,a,1) ++ [{:na,:inf}])],a+1} end)

    inf = List.duplicate({:na, :inf}, length(hd(seq)))
    seq = [ inf | seq ++ [inf]]

    ## We now have a map with :inf squares surrounding the regular
    ## map.

    ## We now build a graph where each square has a set of edges to
    ## squares with higher or equal values. Squares width height 9 or
    ## :inf are not included in the graph.

    ## In the process, the low points are identified. 
    {graph, low} = scanb(seq, %{}, [])

    ## We know (take for granted) that no square belongs to two
    ## basins. This is not clearly stated but since we do not have any
    ## rules on how to treat a situation when a sqaure borders two
    ## basins.

    ## For each of the low points, calculate the area of the basin
    ## given the graph. 

    {sizes, _} = List.foldl(low, {[],graph}, fn(l, {a,g}) -> {s,g} = basin([l], 0, g); {a++[s],g} end)

    List.to_tuple(Enum.take(Enum.sort(sizes, &>/2), 3))
  end

  ## The area of the basin is calculated recusivly given a list of
  ## squares left to evaluate. If the list is empty we are done
  ## otherwise we pick the first squre and remove it from the graph
  ## (we do not want to double count) and evaluate the area of the
  ## basin starting in this square.

  ## Since the graph is directed and only have vertices leading to
  ## higher (or equal) squares we will eventually reach sqaures with
  ## no higher neighbours. Remember that the ridges of height 9 are
  ## not included in the graph.
  
  def basin([], s, g) do {s, g} end
  def basin([x|rest], s, g) do
    case Map.pop(g, x, :no) do
      {:no, g} ->
	## This is a case where we stumble on the same square twice. 
	basin(rest, s, g)
      {more, g} ->
	{s, g} = basin(more, s, g)
	basin(rest, s+1, g)	
    end
  end

  ## All squares are given a unique {i,j} name that can later be used
  ## when building the graph. Usning the index (i,j) is not important,
  ## we only need a unique key.
  
  def depth(<<>>,_,_) do [] end
  def depth(<<10>>,_,_) do [] end  
  def depth(<<c, rest::binary>>, i,j) do [{{i,j},c-48}|depth(rest, i,j+1)] end  


  ## The map is scanned with a sliding three by three kernel.  The
  ## dummy rows (with all :inf) as well as the dummy first and last
  ## elements in each row allows us to do this without special cases.
  
  def scanb([_,_], graph, low) do {graph, low} end
  def scanb([north | [this, south | _] = rest] , graph, low) do
    {graph, low} = scanb(north, this, south, graph, low)
    scanb(rest, graph, low)
  end
  
  def scanb([_,_], [_,_], [_,_], graph, low) do {graph,low} end
  def scanb([_,n,ne|rn], [_,{_,9}=t,e|rt],[_,s,se|rs], graph, low) do 
    ## We skip squares of height 9 since they will not be part of any
    ## basin.
    scanb([n,ne|rn], [t,e|rt], [s,se|rs], graph, low)
  end
  def scanb(
    ##  Select the nort, west, east and south neighbours.
    [ _  | [   n | _] = rn],
    [ w  | [{ti,td},  e | _] = rt],
    [ _  | [   s | _] = rs],  graph, low) do 

    ##  Filter out the higher or equal.
    higher =  Enum.filter([n,w,e,s], fn({_,d}) -> d >= td end)

    ##  If all four are strictly higher we have a low point. 
    low = if length(Enum.filter(higher, fn({_,d}) -> d > td end)) == 4 do
      [ti|low]
    else
      low
    end

    ## The basin of the square are those squares that are higher or equal, not
    ## including 9 nor :inf. 

    basin = List.foldl(higher, [], fn({pos, depth}, a) -> if (depth != :inf) && (depth != 9), do: [pos|a], else: a end)

    scanb(rn, rt, rs, Map.put(graph, ti, basin), low)
  end
    
  ##==================================================================

  def day10a() do
    seq = File.stream!("day10.csv") |>
      Enum.map(fn(row) -> parse(String.trim(row, "\n")) end)
    score(seq)
  end

  def score(seq) do
    List.foldl(seq, 0, fn (res, a) ->
      a + case res do
	    {:error, ?), _} -> 3
            {:error, ?], _} -> 57
            {:error, ?}, _} -> 1197
	    {:error, ?>, _} -> 25137
            {:incmpl, _}  -> 0
            :ok -> 0
          end			      
      end)      
  end
  
  def parse(<<>>) do {:ok, <<>>} end
  def parse(<<open, rest::binary>>) do  
    case close(rest, closer(open), []) do
      {:ok, rest} ->
	parse(rest)
      error ->
	error
    end
  end

  def close(<<>>, c, incmpl) do {:incmpl, [c|incmpl]} end
  def close(<<c, rest::binary>>, c, _) do {:ok, rest} end
  def close(<<?>, _::binary>>, c, _) do {:error, ?>, c} end
  def close(<<?), _::binary>>, c, _) do {:error, ?), c} end
  def close(<<?}, _::binary>>, c, _) do {:error, ?}, c} end
  def close(<<?], _::binary>>, c, _) do {:error, ?], c} end

  def close(<<open, rest::binary>>, c, incmpl) do
       case close(rest,closer(open), [c|incmpl]) do
         {:ok, rest} ->
           close(rest,c, incmpl)
         error ->
           error
       end
  end

  def closer(?<) do ?> end
  def closer(?{) do ?} end
  def closer(?() do ?) end
  def closer(?[) do ?] end

  def day10b() do
    seq = File.stream!("day10.csv") |>
      Enum.map(fn(row) -> parse(String.trim(row, "\n")) end) |>
        Enum.filter(fn(res) -> case res do
				 {:incmpl,_} -> true
				 _ -> false
				 end end)
    Enum.fetch(Enum.sort(scoreb(seq)), trunc(length(seq)/2))
  end

  def scoreb(seq) do
    Enum.map(seq, fn (res) ->
        case res do
	    {:error, _, _} -> 0
            {:incmpl, missing}  -> List.foldl(missing, 0, fn(c,a) ->
                                       a*5 + case c do
						?) -> 1
						?] -> 2
						?} -> 3
						?> -> 4
					     end
                                        end)
	     :ok -> 0
          end			      
      end)      
  end
end

  
