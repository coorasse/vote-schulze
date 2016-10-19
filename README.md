# Schulze Vote

This gem is a Ruby implementation of the Schulze voting method (with help of the Floyd–Warshall algorithm), 
a type of the Condorcet voting methods.

## Master

[![Build Status](https://travis-ci.org/coorasse/schulze-vote.svg?branch=master)](https://travis-ci.org/coorasse/schulze-vote)

## Develop

[![Build Status](https://travis-ci.org/coorasse/schulze-vote.svg?branch=develop)](https://travis-ci.org/coorasse/schulze-vote)

[![Code Climate](https://codeclimate.com/github/coorasse/schulze-vote/badges/gpa.svg)](https://codeclimate.com/github/coorasse/schulze-vote)



Wikipedia:

* [Schulze method](http://en.wikipedia.org/wiki/Schulze_method) ([deutsch](http://de.wikipedia.org/wiki/Schulze-Methode))
* [Floyd–Warshall algorithm](http://en.wikipedia.org/wiki/Floyd%E2%80%93Warshall_algorithm)

## Install

``` bash
gem install schulze-vote
```

Gemfile

``` ruby
gem 'schulze-vote', require: 'schulze_vote'
```

## Usage

``` ruby
require 'schulze_vote'
vs = SchulzeBasic.do vote_list, candidate_count
vs.ranks
```

`SchulzeBasic.do` - SchulzeBasic is a short term for `Vote::Condorcet::Schulze::Basic` and `.do` is a method of this class!

Input:

* `vote_list`
  * Array of Arrays: votes of each voter as weights `[ [A,B,C,...],[A,B,C,...],[A,B,C,...] ]`
  * String: "A;B;C\nA;B;C\n;3=A;B;C..."
  * File: first line **must** be a single integer, following lines like vote_list type String (see vote lists under `examples` directory)
* `candidate_count` Integer: number of candidates
  * **required** for vote_list types of Array and String
  * _leave empty if vote_list is a File handle!_

### String/File format:

A typical voters line looks like this:

```
A;B;C;D;E;F
```

You also can say that _n_ voters have the same preferences:

```
n=F;E;D;C;B;A
```

where _n_ is an integer value for the count.

Also it's possible to say that a voter has candidates equally weighted:

```
A,B;C,D;E,F
```

which means, that A + B, C + D and E + F are on the same weight level.

Here only 3 weight levels are used: (A,B) = 3, (C,D) = 2, (E,F) = 1

### Why I must write the candidate count in the first line of the vote file?

_or: Why I must give a candidate count value for Array/String inputs?_

Very easy: The reason is, that voters can leave out candidates (they give no special preferences).

So, schulze-vote needs to know, how many real candidates are in the voting process.

Okay, for Array inputs it's currently a little bit overhead, because the voters array normally should have the size of the candidates count.
See it as an visual reminder while coding with this gem.

### Examples

#### Array

(Only weight values, no letters here! See section "_preference order to weight_ example")

``` ruby
require 'schulze_vote'
vote_list_array = [[3,2,1],[1,3,2],[3,1,2]]
vs = SchulzeBasic.do vote_list_array, 3
```

#### String

``` ruby
require 'schulze_vote'
vote_list_string = <<EOF
A;B;C
B;C;A
A;C;B
A,C,B
4=C;A;B
EOF
vs = SchulzeBasic.do vote_list_string, 3
```

#### File

``` ruby
require 'schulze_vote'
vs = SchulzeBasic.do File.open('path/to/vote.list')
```

### _preference order to weight_ example

```
voter  => A D C B

weight => 4,1,2,3

A is on first position = highest prio == 4
B is on last position                 == 1
C is on third position                == 2
D is on second position               == 3
```

Later versions will have an automatic Preference-to-Weight algorithm.
(Internally only integers are used for calculation of ranking.)

### _SchulzeBasic_

It doesn't matter if you start counting at 0 (zero) or 1 (one).

Also it's not important, if you use jumps (like `1 3 5 9`).

Internally it will only check if candidate X > candidate Y

Output:

* `.ranks` Array: numbers of total wins for each candidate `[candidate A, candidate B, candidate C, ...]`
* `.winners_array` Array: set 1 if the candidate is a potential winner `[candidate A, candidate B, candidate C, ...]`

## Example

Example 1 from Wikipedia

https://en.wikipedia.org/wiki/User:MarkusSchulze/Schulze_method_examples

Result should be:

``` ruby
votestring = <<EOF
5=A;C;B;E;D
5=A;D;E;C;B
8=B;E;D;A;C
3=C;A;B;E;D
7=C;A;E;B;D
2=C;B;A;D;E
7=D;C;E;B;A
8=E;B;A;D;C
EOF
vs = SchulzeBasic.do votestring, 5
puts_m vs.vote_matrix

#=> [0, 20, 26, 30, 22]
    [25, 0, 16, 33, 18]
    [19, 29, 0, 17, 24]
    [15, 12, 28, 0, 14]
    [23, 27, 21, 31, 0]
   
puts_m vs.play_matrix

#=> [0, 28, 28, 30, 24]
    [25, 0, 28, 33, 24]
    [25, 29, 0, 29, 24]
    [25, 28, 28, 0, 24]
    [25, 28, 28, 31, 0]

puts vs.winners_array.to_s

#=> [0, 0, 0, 0, 1]

puts_m vs.result_matrix

#=> [0, 1, 1, 1, 0]
    [0, 0, 0, 1, 0]
    [0, 1, 0, 1, 0]
    [0, 0, 0, 0, 0]
    [1, 1, 1, 1, 0]

vs.classifications.each do |classification|
  puts classification.map { |e| idx_to_chr(e) }.to_s
end

#=> ["E", "A", "C", "B", "D"]
```

which is the same result of the reference above.

## Classifications

You have a `classifications(limit_results = false)` that you can call.
If the number of results is greater then the `limit_results` parameter then a `TooManyClassificationsException`
is raised.
If you set this parameter to any value other then `false` be careful to catch and manage the exception properly.

## Classification with ties

You have a `classification_with_ties` that you can call.
This method return a uniq classification in array of arrays format to display results on screen.
Please note that for cases like this: https://en.wikipedia.org/wiki/User:MarkusSchulze/Schulze_method_examples#Example_4 
it will return the following: [[B,D], [A,C]]

## Contributing to schulze-vote

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Use git-flow
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Problems? Questions?

![Alessandro Rodi](http://www.gravatar.com/avatar/32d80da41830a6e6c1bb3eb977537e3e)

## Thanks

Thanks to Christoph Grabo for providing the idea and base code of the gem

## Copyright

See LICENSE for further details.

