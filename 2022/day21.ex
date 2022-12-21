defmodule Day21 do



  def task_a() do
    {ops, nrs} = input() |>
      parse() |>
      Enum.reduce({Map.new(), Map.new()} , fn(spec, {ops,nrs}) ->
	{name, op} = spec
	case op do
	  {:nr, nr} ->
	    {ops, Map.put(nrs, name, nr)}
	  _ ->
	    {Map.put(ops, name, op), nrs}
	end
	end)
    {nr, _} = call_out(:root, ops, nrs)
    nr
  end

  def task_b() do
    {ops, nrs} = input() |>
      parse() |>
      Enum.reduce({Map.new(), Map.new()} , fn(spec, {ops,nrs}) ->
	{name, op} = spec
	case op do
	  {:nr, nr} ->
	    {ops, Map.put(nrs, name, nr)}
	  _ ->
	    {Map.put(ops, name, op), nrs}
	end
	end)
    root(ops, nrs)
  end



  def root(ops, nrs) do
    {_, name1, name2} = Map.get(ops, :root)
    {n1, nrs} = call_out(name1, ops, nrs)
    {n2, _nrs} = call_out(name2, ops, nrs)
    solve(n1,n2)
  end

  def solve(:humn, nr) do  nr end
  def solve({op, nr1, expr}, nr) when is_number(nr1) do
    case op do
      :add ->
	solve(expr, nr - nr1)
      :sub ->
	solve(expr, nr1 - nr)
      :mul ->
	solve(expr, nr / nr1)	
      :div ->
	solve(expr, nr1 / nr)
    end
  end
  def solve({op, expr, nr2}, nr) when is_number(nr2) do
    case op do
      :add ->
	solve(expr, nr - nr2)
      :sub ->
	solve(expr, nr + nr2)
      :mul ->
	solve(expr, nr / nr2)	
      :div ->
	solve(expr, nr * nr2)
    end
  end  
  

  def call_out(:humn, _, nrs) do
    {:humn, nrs}
  end
  
  def call_out(name, ops, nrs) do
    case Map.get(nrs, name) do 
      nil ->
	{op, name1, name2} = Map.get(ops, name)
	{nr1, nrs} = call_out(name1, ops, nrs)
	{nr2, nrs} = call_out(name2, ops, nrs)
	nr = op(op, nr1, nr2)
	nrs = Map.put(nrs, name, nr)
	{nr, nrs}
      nr ->
	{nr, nrs}
    end
  end
  

  def op(op, x, y) when is_number(x) and is_number(y) do 
    case op do 
       :add -> x + y
      :sub -> x - y
      :mul -> x * y
      :div -> x/ y
    end
  end
  def op(op, x, y) do {op, x, y} end
  
  def parse(rows) do
    
    Enum.map(rows, fn(row) ->
      [name, ops] = String.split(String.trim(row), ": ")
      name = String.to_atom(String.trim(name))
      case String.split(ops, [" "]) do
	[nr] -> 
	  {nr,_} = Integer.parse(nr)
	  {name, {:nr, nr}}
	[name1, op, name2] ->
	  {name, {op(op), String.to_atom(name1), String.to_atom(name2)}}
      end	  
    end)
  end

  def op("+") do :add end
  def op("-") do :sub end
  def op("*") do :mul end    
  def op("/") do :div end      


  def input() do
    File.stream!("day21.csv")
  end
    

  
  def sample() do
    ["root: pppw + sjmn",
     "dbpl: 5",
     "cczh: sllz + lgvd",
     "zczc: 2",
     "ptdq: humn - dvpt",
     "dvpt: 3",

     "lfqf: 4",
     "humn: 5",
     "ljgn: 2",
     "sjmn: drzm * dbpl",
     "sllz: 4",
     "pppw: cczh / lfqf",
     "lgvd: ljgn * ptdq",
     "drzm: hmdt - zczc",
     "hmdt: 32"]
  end
  

  
end
