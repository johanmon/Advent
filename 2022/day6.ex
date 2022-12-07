defmodule Day6 do

  ##  Day 6 first part was a quick and dirty implementation since we
  ##  only had four positions to scan. The second part was more tricky
  ##  in that we had to implement a general solution (well, ok one
  ##  could have done an explicit implementation but that would be
  ##  ... a lot of code). The general sultion does not return the
  ##  start-of-message sequence. It's tricky to follow the code as it
  ##  is - could probably been done in a more elegant way.

  def task_a() do
    {:ok, <<a,b,c,d, rest::binary>>} = File.read("day6.csv")
    {mrk, n, _} = marker(a, b, c, d, rest, 4)
    {mrk, n}
  end

  ##  checking that the message function is ok
  def task_aa() do
    {:ok, input} = File.read("day6.csv")
    {:ok, n, _} = message(to_charlist(input), 4, 0)
    {:ok, n+4}
  end
  
  def task_b(k) do
    {:ok,input} = File.read("day6.csv")
    <<a,b,c,d, rest::binary>> = input
    {_, n, rest} = marker(a, b, c, d, rest, 0)
    {:ok, c, _} = message(to_charlist(rest), k, 0)
    {:ok, c + n}
  end
    
  ## The explicit solution, why not - not a lot of code
  
  def marker(a, a, c, d, <<e, rest::binary>>, n) do
    marker(a, c, d, e, rest, n+1)
  end
  def marker(a, b, a, d, <<e, rest::binary>>, n) do
    marker(b, a, d, e, rest, n+1)
  end  
  def marker(a, b, c, a, <<e, rest::binary>>, n) do
    marker(b, c, a, e, rest, n+1)
  end  
  def marker(_, b, b, d, <<e, f, rest::binary>>, n) do
    marker(b, d, e, f, rest, n+2)
  end    
  def marker(_, b, c, b, <<e, f, rest::binary>>, n) do
    marker(c, b, e, f, rest, n+2)
  end      
  def marker(_, _, c, c, <<e, f, g, rest::binary>>, n) do
    marker(c, e, f, g, rest, n+3)
  end      
  def marker(a, b, c, d, rest, n) do
    {[a,b,c,d], n+4, rest}
  end      

  ## The general solution, does not return the start-of-message
  ## sequence.
  
  def message([a|rest], k, n) do
    case msg(a, rest, k) do
      {:cont, rest, c} -> message(rest, k, n + (k-c) + 1)
      {:found, rest} -> {:ok, n+k, rest}
    end
  end

  def msg(_, rest, 1) do {:found, rest} end
  def msg(a, rest, k) do
    case ms(a, rest, k) do
      :cont -> {:cont, rest, k}
      :clear -> msg(hd(rest), tl(rest), k-1)
    end
  end
  
  def ms(_, _, 1) do :clear end
  def ms(a, rest, j) do
    case rest do
      [^a|_] ->  :cont
      [_|rest] -> ms(a, rest, j-1)
    end
  end
  
  ## A test to see if we can do better by simply sorting the
  ## sequence. The solution might be a bit easier to follow; we first
  ## take a subsequence of 14 (k) characters, number them and sort
  ## them alphabetically. Now we can simplu scan the sorted sequence
  ## (in msg2) looking for the duplicate with the higeste index (if we
  ## have one duplicate at position 2 and 6 and another at 5 and 9 we
  ## return 5 i.e. the number of characters that we can skip. 
  ##
  ## The solution does have a better complexity O(n*k*lg(k)) compared
  ## to O(n*k^2) but does not outperform the first solution (at least
  ## not for k = 14).

  def task_bb(k) do
    {:ok,input} = File.read("day6.csv")
    <<a,b,c,d, rest::binary>> = input
    {_, n, rest} = marker(a, b, c, d, rest, 0)
    {:found, c, _} = message2(to_charlist(rest), k, 0)
    {:ok, c + n}
  end

  def message2(seq, k, n) do
    first = Enum.take(seq, k)
    {0, first} = List.foldr(first, {k,[]}, fn(c,{i,a}) -> {i-1, [{c,i}|a]} end)
    first = Enum.sort(first, fn({x,_},{y,_}) -> x < y end)
    case msg2(first, 0) do
      :found -> {:found,  n+k, Enum.drop(seq, k)}
      {:cont, j} -> message2(Enum.drop(seq, j), k, n+j)
    end
  end

  def msg2([_], 0) do :found end
  def msg2([_], m) do {:cont, m} end  
  def msg2([{a,i}|[{a,j}|_]=rest], m) do
    msg2(rest,  max(m, min(i,j)))
  end
  def msg2([_|rest], m) do
    msg2(rest, m)
  end


end


