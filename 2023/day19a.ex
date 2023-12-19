defmodule Day19a do

  ## No problem, simply apply the rules and all will be fine. In the
  ## solution below much of the prepatory work is done in the parser
  ## since we know what we are going to use the rules for.
  ##
  ## In my first solution the parser returned items like:
  ##
  ##    {:dir, 2, :le, 2304, :pkq}
  ##
  ## The sorter would then have to interpret this and check if the
  ## current part would pass the test. In the solution below the
  ## parser returns something like this:
  ##
  ##    {:dit, fn(part) -> if elem(part,2) < 2304 then 
  ##                         {:pass, :pkg}
  ##                       else 
  ##                         :fail 
  ##                       end 
  ##            end}
  ##
  ## The sorter now only has to apply the functions and follow the
  ## directions.
  ##
  ## 
  
  def test() do
    sample() |>
      parse() |>
      sort() |>
      sum()
  end

  def task() do
    File.read!("day19.csv") |>
      parse() |>
      sort() |>
      sum()
  end  

  def sum(parts) do
    Enum.reduce(parts, 0, fn({x,m,a,s}, sum) -> x+m+a+s+sum end)
  end
  
  def sort({rules, parts}) do
    Enum.reduce(parts, [], fn(part, acc) ->
      sort(:in, part, rules) ++ acc
    end)
  end


  ## Does it pass all of the test? 
  
  def sort(:A, part, _rules) do  [part] end
  def sort(:R, _part, _rules) do [] end
  def sort(rule, part, rules) do
    cont(Map.get(rules, rule), part, rules)
  end

  def cont([{:dir, pass}|rest], part, rules) do
    case pass.(part) do
      {:pass, dest} ->
	sort(dest, part, rules)
      :fail ->
	cont(rest, part, rules)
    end
  end

  ## The parser 
  
  def parse(instr) do
    [rules, parts] = String.split(instr, "\n\n")
    rules = parse_rules(rules)
    parts = parse_parts(parts)
    {rules, parts}
  end

  def parse_rules(rules) do
    Enum.reduce(String.split(rules, "\n"), %{}, fn(rule, acc) ->
      [name | rule] = String.split(rule, ["{", ",", "}"])
      rule = Enum.drop(rule, -1)
      name = String.to_atom(name)
      rule = Enum.map(rule, fn(dir) ->
	case String.split(dir, ":") do 
	  [<<attr, op, nr::binary>>, dest] ->
	    {limit, _} = Integer.parse(nr)
	    attr = parse_attr(attr)
	    op = parse_op(op)	    
	    dest = String.to_atom(dest)
  	    {:dir, fn(part) ->
	      if op.(elem(part, attr),limit) do
		{:pass, dest}
	      else
		:fail
	      end
	    end}
	  [dest] ->
	    dest = String.to_atom(dest)
	    {:dir, fn(_) -> {:pass, dest} end}
	end
      end)
      Map.put(acc, name, rule)
    end)
  end   

  def parse_attr(?x) do 0 end
  def parse_attr(?m) do 1 end
  def parse_attr(?a) do 2 end
  def parse_attr(?s) do 3 end  

  def parse_op(?<) do &</2 end
  def parse_op(?>) do &>/2 end
  
  def parse_parts(parts) do
    Enum.map(String.split(parts, "\n"), fn(part) ->
      descr = Enum.drop(Enum.drop(String.split(part, ["{", ",", "}"]), 1), -1)
      xmas = Enum.map(descr, fn(desc) ->
	<<_attr, ?=, nr::binary>> = desc
	{prop, _} = Integer.parse(nr)	
	prop
      end)
      List.to_tuple(xmas)
    end)
  end
	  
  

  def sample() do
"px{a<2006:qkq,m>2090:A,rfg}
pv{a>1716:R,A}
lnx{m>1548:A,A}
rfg{s<537:gd,x>2440:R,A}
qs{s>3448:A,lnx}
qkq{x<1416:A,crn}
crn{x>2662:A,R}
in{s<1351:px,qqz}
qqz{s>2770:qs,m<1801:hdj,R}
gd{a>3333:R,R}
hdj{m>838:A,pv}

{x=787,m=2655,a=1222,s=2876}
{x=1679,m=44,a=2067,s=496}
{x=2036,m=264,a=79,s=2244}
{x=2461,m=1339,a=466,s=291}
{x=2127,m=1623,a=2188,s=1013}"
  end




end

  
