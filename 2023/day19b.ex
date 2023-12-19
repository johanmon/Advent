defmodule Day19b do

  ## The simple part was finding a way to represent the parts that
  ## would pass the test. It was obvious from the beginning that
  ## trying all possible combinations was doomed to fail so one had to
  ## be smarter. The strategy I came up with was to start with a part
  ## that represented all parts:
  ##
  ##              {{1,4000}, {1,4000}, {1,4000}, {1,4000}
  ##
  ## Now when we try the first test in the first rule we have some
  ## possibilities. Assume we're in state px and rule is:
  ##
  ##              px{a<2006:qkq,m>2090:A,rfg}    
  ##
  ## We then constrain the ranges that we have if possible. The
  ## test a < 2006 will create two parts, one that passes and one
  ## that fails:
  ##
  ##          passes = {{1,4000}, {1,4000}, {1,2005}, {1,4000}
  ##
  ##          failes = {{1,4000}, {1,4000}, {2006,4000}, {1,4000}
  ##
  ## The part that passes continues with rule qkq and the part that
  ## fails takes the next test in the sequence.
  ##
  ## The accept state will collect the part and all parts that are
  ## accepted are then returned in a list. 
  ##
  ## After applying all the rules we are left with a list of 543
  ## parts. Each part of course now represents thousands of parts.
  ## The important observation is that the parts are distinct i.e. the
  ## ranges do not overlap. This is clear since every time we split a
  ## part we divide it into distinct subsets.

  def test() do
    sample() |>
      parse() |>
      combinations() |>
      sum()
  end

  def task() do
    File.read!("day19.csv") |>
      parse() |>
      combinations() |>
      sum()
  end

  def sum(parts) do
      Enum.reduce(parts, 0, fn({{x1,x2}, {m1,m2}, {a1,a2}, {s1,s2}}, acc) ->
        (x2-x1+1)*(m2-m1+1)*(a2-a1+1)*(s2-s1+1) + acc
      end)
  end

  ## The combinations is almost as the sort/1 in the first task. The
  ## difference is that we now start with a dummy part with complete
  ## ranges {{1,400}, {1,400}, {1,400}, {1,400}}. We then apply the
  ## rules and for each test explore the different scenarios:
  ##
  ##    fails the test and continues,
  ##    passes the test and move to the next named rule or
  ##    splits into two parts, the failed and the passed.
  ##
  ##
  
  def combinations(rules) do
    combinations(:in, full(), rules)
  end
  
  def full() do
    range = {1,4000}
    {range, range, range, range}
  end
  
  def combinations(:A, part, _rules) do [part] end
  def combinations(:R, _part, _rules) do [] end
  def combinations(rule, part, rules) do
    ## :io.format(" apply rule ~w ~n", [rule])
    combine(Map.get(rules, rule), part, rules)
  end

  def combine([{:dir, pass}|rest], part, rules) do
    case pass.(part) do
      :nil ->
	combine(rest, part, rules)
      {:split, failed, {:pass, passed, dest}} ->
	combine(rest, failed, rules) ++ combinations(dest, passed, rules)	
      {:pass, passed, dest}->
	combinations(dest, passed, rules)
    end
  end

  ## The parser, the change is the contruction of the pass
  ## function. This is now more compliceted sice we have to
  ## calculate the failed and passed versions of the part.
  
  def parse(instr) do
    [rules, _parts] = String.split(instr, "\n\n")
    parse_rules(rules)
  end

  def parse_rules(rules) do
    Enum.reduce(String.split(rules, "\n"), %{}, fn(rule, acc) ->
      [name | rule] = String.split(rule, ["{", ",", "}"])
      rule = Enum.drop(rule, -1)
      name = String.to_atom(name)
      rule = Enum.map(rule, fn(dir) ->
	case String.split(dir, ":") do 
	  [<<attr, ?<, nr::binary>>, dest] ->
	    {limit, _} = Integer.parse(nr)
	    attr = parse_attr(attr)
	    dest = String.to_atom(dest)
	    {:dir, fn(part) ->
	      {i,j} = elem(part,attr)
	      if i < limit do
		if j < limit do
		  {:pass, put_elem(part, attr, {i, j}), dest}
		else
		  {:split, put_elem(part, attr, {limit,j}),
		   {:pass, put_elem(part, attr, {i, limit-1}), dest}}
		end
	      else
		:nil
	      end
	    end}
	  [<<attr, ?>, nr::binary>>, dest] ->
	    {limit, _} = Integer.parse(nr)
	    attr = parse_attr(attr)
	    dest = String.to_atom(dest)
	    {:dir, fn(part) ->
	      {i,j} = elem(part,attr)
	      if j > limit do
		if i > limit do 
		  {:pass, put_elem(part, attr, {i,j}), dest}
		else
		  {:split, put_elem(part, attr, {i,limit}),
		   {:pass, put_elem(part, attr, {limit+1,j}), dest}}
		end
	      else
		:nil
	      end
	    end}
	  [dest] ->
	    dest = String.to_atom(dest)
	    {:dir, fn(part) -> {:pass, part, dest} end}
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

  
