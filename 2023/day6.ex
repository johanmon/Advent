defmodule  Day6 do

  ## Fairly easy puzzle. The input was so small that I didn't bother
  ## writing a parser (which cost me 10 min of debugging ... argh!
  ## 
  ## The only fix in the first problem was to start the search as late
  ## as possible by realizing that the speed needed to be at least the
  ## distance divided by the total time.
  ##
  ## The second problem was easily solved by only searching for the
  ## two end positions. Fortunately the first possible time to try
  ## (d/t = 5913274) was not far from the first possible time
  ## (6915807). Same thing for the last time, very close to the end. 


  ##  A solution, that was only thought of after having solved the
  ##  puzzle is to iterat the lower bound starting value until the
  ##  true lower bound is found.
  ##
  ##   282/47 ->  at least 6 mm/ms -> 6 ms of charging
  ##              this would only leav 47-6 = 41 ms of running
  ##
  ##   282/41 ->  at least 7 mm/ms ->  40 ms of running
  ##
  ##   282/40 ->  at leats 8 mm/ms ->  39 ms of running
  ##
  ##   282/39 ->  ok 8 mm/s will do it ergo 8 ms of charging   
  ##
  ## The interesting thing is that we coudl of course do the same
  ## iteration to look for the higher bound but ... we have all ready
  ## found it:
  ##
  ##   282 mm / 39 ms = 8 mm/ms i.e. we have the speed required
  ##
  ##   282 mm / 39 mm/ms = 8 ms i.e. the time it takes
  ##
  ## In the first solution we have the speed of 8 mm/ms whoch requires
  ## 8 ms of charging. In the second solution we have a speed of 39
  ## mm/ms wich requires 39 ms of charging. These are the two boundry
  ## values. This is of course the way to solve it but you're so eager
  ## to find a solution as fast as possible and code rathe rthan think
  ## :-)
  ##
  ##


  def test_a() do
    List.foldl(Enum.map(sample_a(), fn({:race, t, d}) -> winning_a(t,d) end), 1, fn(x,a) -> x*a end)
  end

  def task_a() do
    List.foldl(Enum.map(input_a(), fn({:race, t, d}) -> winning_a(t,d) end),  1, fn(x,a) -> x*a end)
  end

  def test_b() do
    List.foldl(Enum.map(sample_b(), fn({:race, t, d}) -> winning_b(t,d) end), 1, fn(x,a) -> x*a end)
  end

  def task_b() do
    List.foldl(Enum.map(input_b(), fn({:race, t, d}) -> winning_b(t,d) end),  1, fn(x,a) -> x*a end)
  end    


  def test_x() do
    List.foldl(Enum.map(sample_a(), fn({:race, t, d}) -> winning_x(t,d) end), 1, fn(x,a) -> x*a end)
  end

  def task_x() do
    List.foldl(Enum.map(input_b(), fn({:race, t, d}) -> winning_x(t,d) end),  1, fn(x,a) -> x*a end)
  end      
  

  def winning_a(t, d) do
    ##   hold for k ms  (k > 0 & k < t)
    ##   boat travels (t-k)*k mm
    ##   
    ##   (t-k)*k > d
    ##   (t-k) > d/k
    ##    
    ##   ergo:  t > d/k  ->  k > d/t
    possible = Enum.filter(trunc(d/t)..(t-1), fn(k) -> (t-k)*k > d end)
    :io.format("possible: ~w~n", [possible])
    length(possible)
  end

  def winning_b(t, d) do
    ## find the first and last possible 
    first = Enum.find(trunc(d/t)..(t-1), fn(k) -> (t-k)*k > d end)
    last = Enum.find((t-1)..first, fn(k) -> (t-k)*k > d end)
    :io.format(" first = ~w  last = ~w~n", [first, last])
    last - first + 1
  end

  ## The solution found only after having solved the puszzle. 

  def winning_x(t, d) do
    first = winning_x(t, d, ceil(d/t))
    last = t - first
    :io.format(" first = ~w  last = ~w~n", [first, last])
    last - first + 1
  end

  ## It's easy to end up in a loop ( 200/(30-10) == 10 ) and it's not
  ## enough to have a tie, you have to go further i.e. k+1.
  
  def winning_x(t, d, k) do
    cond do 
      (t-k)*k > d ->
	k
      (t-k)*k == d ->
	k+1
      true ->
	winning_x(t, d, ceil(d/(t-k)))
    end
  end
  

  def input_a() do
    [{:race, 47, 282}, {:race, 70, 1079}, {:race, 75, 1147}, {:race, 66,1062}]
  end
  
  ##  Time:        47     70     75     66
  ##  Distance:   282   1079   1147   1062


  def input_b() do
    [{:race, 47707566, 282107911471062}]
  end
  
  ##  Time:              47707566   
  ##  Distance:   282107911471062
  
  
  def sample_a() do
    [{:race, 7, 9}, {:race, 15, 40}, {:race, 30, 200}]
  end
  
  ## Time:      7  15   30
  ## Distance:  9  40  200"

  def sample_b() do
    [{:race, 71530, 940200}]
  end
  
  ## Time:       71530
  ## Distance:  940200"  

end
