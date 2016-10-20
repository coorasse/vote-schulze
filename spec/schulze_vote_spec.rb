require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

def puts_m(matrix)
  puts matrix.to_a.map(&:inspect)
end

def idx_to_chr(idx)
  (idx + 65).chr
end

describe 'SchulzeVote' do
  describe 'works with numbers' do
    it '22 wins' do
      votestring = <<EOF
30;10;22
30;22;10
10;22;30
10;30;22
22;30;10
2=22;10;30
EOF
      vs = SchulzeBasic.do votestring, 3

      # if we order the numbers:
      # A = 10, B: 20, C: 30
      # solution ==> 20, 10, 30 - B, A, C
      SchulzeClassifications.new(vs).classifications.each do |classification|
        puts classification.map { |e| idx_to_chr(e) }.to_s
      end
      expect(vs.ranking).to eq [1, 2, 0]
    end

    it '10 wins' do
      votestring = <<EOF
10;2;1
EOF
      vs = SchulzeBasic.do votestring, 3

      # if we order the numbers:
      # A = 1, B: 2, C: 10
      # solution ==> 10, 2, 1 - C, B, A
      # wrong solution ==> A = 1, B: 10, C: 2 --> B, C, A
      SchulzeClassifications.new(vs).classifications.each do |classification|
        puts classification.map { |e| idx_to_chr(e) }.to_s
      end
      expect(vs.ranking).to eq [0, 1, 2]
    end
  end

  describe 'README examples' do
    it 'runs example one' do
      vote_list_array = [[3, 2, 1], [1, 3, 2], [3, 1, 2]]
      vs = SchulzeBasic.do vote_list_array, 3
      expect(vs.ranking).to eq [2, 1, 0]
    end
  end

  describe 'really simple vote with A=B' do
    it 'can solve a simple votation' do
      # the vote is A > B
      votestring = 'A,B'
      vs = SchulzeBasic.do votestring, 2
      expect(vs.ranking).to eq [0, 0]
    end

    it 'can solve a simple votation with the number of votes preceeding' do
      # the vote is A = B
      votestring = '1=A,B'
      vs = SchulzeBasic.do votestring, 2
      expect(vs.ranking).to eq [0, 0]
    end

    it 'with two votes the result is the same' do
      # the vote is A = B
      votestring = '2=A,B'
      vs = SchulzeBasic.do votestring, 2
      expect(vs.ranking).to eq [0, 0]
    end

    it 'with hundred votes the result is the same' do
      # the vote is A = B
      votestring = '100=A,B'
      vs = SchulzeBasic.do votestring, 2
      expect(vs.ranking).to eq [0, 0]
    end
  end

  describe 'really simple vote with A>B' do
    it 'can solve a simple votation' do
      # the vote is A > B
      votestring = 'A;B'
      vs = SchulzeBasic.do votestring, 2
      expect(vs.ranking).to eq [1, 0]
    end

    it 'can solve a simple votation with the number of votes preceeding' do
      # the vote is A > B
      votestring = '1=A;B'
      vs = SchulzeBasic.do votestring, 2
      expect(vs.ranking).to eq [1, 0]
    end

    it 'with two votes the result is the same' do
      # the vote is A > B
      votestring = '2=A;B'
      vs = SchulzeBasic.do votestring, 2
      expect(vs.ranking).to eq [1, 0]
    end

    it 'with hundred votes the result is the same' do
      # the vote is A > B
      votestring = '100=A;B'
      vs = SchulzeBasic.do votestring, 2
      expect(vs.ranking).to eq [1, 0]
    end
  end

  describe 'two votes, one opposite of the other' do
    it 'can solve a simple votation' do
      # the vote is A > B
      votestring = <<EOF
A;B
B;A
EOF
      vs = SchulzeBasic.do votestring, 2
      expect(vs.ranking).to eq [0, 0]
    end

    it 'can solve a simple votation with the number of votes preceeding' do
      votestring = <<EOF
1=A;B
1=B;A
EOF
      vs = SchulzeBasic.do votestring, 2
      expect(vs.ranking).to eq [0, 0]
    end

    it 'with two votes the result is the same' do
      votestring = <<EOF
2=A;B
2=B;A
EOF
      vs = SchulzeBasic.do votestring, 2
      expect(vs.ranking).to eq [0, 0]
    end

    it 'with hundred votes the result is the same' do
      votestring = <<EOF
100=A;B
100=B;A
EOF
      vs = SchulzeBasic.do votestring, 2
      vc = SchulzeClassifications.new(vs)
      expect(vs.ranking).to eq [0, 0]
      expect(vc.classifications(false)).to eq [[0, 1], [1, 0]]
    end
  end

  describe 'more options' do
    it '3 equally voted' do
      votestring = <<EOF
A,B,C
EOF
      vs = SchulzeBasic.do votestring, 3
      expect(vs.ranking).to eq [0, 0, 0]
    end

    it 'wins C' do
      votestring = <<EOF
C;A,B
EOF
      vs = SchulzeBasic.do votestring, 3
      expect(vs.ranking).to eq [0, 0, 2]
    end

    it 'wins A' do
      votestring = <<EOF
A;C,B
EOF
      vs = SchulzeBasic.do votestring, 3
      expect(vs.ranking).to eq [2, 0, 0]
    end

    it 'wins B' do
      votestring = <<EOF
B;C,A
EOF
      vs = SchulzeBasic.do votestring, 3
      expect(vs.ranking).to eq [0, 2, 0]
    end

    it 'wins C against A wins against B' do
      votestring = <<EOF
C;A;B
EOF
      vs = SchulzeBasic.do votestring, 3
      expect(vs.ranking).to eq [1, 0, 2]
    end

    it 'six votes destroy each other' do
      votestring = <<EOF
C;A;B
C;B;A
A;B;C
A;C;B
B;C;A
B;A;C
EOF
      vs = SchulzeBasic.do votestring, 3
      vc = SchulzeClassifications.new(vs)
      expect(vs.ranking).to eq [0, 0, 0]

      [0, 1, 2].permutation.each do |array|
        expect(vc.classifications).to include array
      end
      expect(vc.classification_with_ties).to eq [[0, 1, 2]]
    end

    it 'raises an exception when the vote has too many results' do
      votestring = <<EOF
A,B,C,D
EOF
      vs = SchulzeBasic.do votestring, 4
      vc = SchulzeClassifications.new(vs)
      expect { vc.classifications(0) }.to raise_exception TooManyClassificationsException
      expect { vc.classifications(1) }.to raise_exception TooManyClassificationsException
      expect { vc.classifications(10) }.to raise_exception TooManyClassificationsException
      expect { vc.classifications(23) }.to raise_exception TooManyClassificationsException
      expect { vc.classifications(false) }.not_to raise_exception
      expect { vc.classifications(24) }.not_to raise_exception
      expect { vc.classifications(25) }.not_to raise_exception
      expect(vs.ties).to eq([[0, 1, 2, 3]])
      expect(vc.classification_with_ties).to eq([[0, 1, 2, 3]])
    end

    it 'calculates single classification fast when options are all pair' do
      votestring = <<EOF
A,B,C,D,E,F,G,H,I,J
EOF
      vs = SchulzeBasic.do votestring, 10
      vc = SchulzeClassifications.new(vs)
      expect(vc.classification_with_ties).to eq([[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]])
      expect { vc.classifications(100) }.to raise_exception TooManyClassificationsException
    end

    it 'calculates single classification fast when many options are pair' do
      votestring = <<EOF
A;B,C,D,E,F,G,H,I,J
EOF
      vs = SchulzeBasic.do votestring, 10
      vc = SchulzeClassifications.new(vs)
      expect { vc.classifications(10) }.to raise_exception TooManyClassificationsException
      expect(vc.classification_with_ties).to eq([[0], [1, 2, 3, 4, 5, 6, 7, 8, 9]])
    end

    it 'calculates single classification fast when most options are pair' do
      votestring = <<EOF
A;B;C;D,E,F,G,H,I,J,K,L,M
EOF
      vs = SchulzeBasic.do votestring, 13
      vc = SchulzeClassifications.new(vs)
      expect { vc.classifications(10) }.to raise_exception TooManyClassificationsException
      expect(vc.classification_with_ties).to eq([[0], [1], [2], [3, 4, 5, 6, 7, 8, 9, 10, 11, 12]])
    end

    it 'B wins' do
      votestring = <<EOF
C;A;B
C;B;A
A;B;C
A;C;B
B;C;A
2=B;A;C
EOF
      vs = SchulzeBasic.do votestring, 3
      vc = SchulzeClassifications.new(vs)
      puts_m vs.vote_matrix
      puts
      puts_m vs.play_matrix
      puts
      puts vs.winners_array.to_s
      puts
      puts_m vs.result_matrix
      puts
      vc.classifications.each do |classification|
        puts classification.map { |e| idx_to_chr(e) }.to_s
      end
      expect(vs.ranking).to eq [1, 2, 0]
    end
  end

  describe 'complex situation' do
    # see http://en.wikipedia.org/wiki/User:MarkusSchulze/Schulze_method_examples
    it 'example 1 from wikipedia' do
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
      vc = SchulzeClassifications.new(vs)
      puts_m vs.vote_matrix
      puts
      puts_m vs.play_matrix
      puts
      puts vs.winners_array.to_s
      puts
      puts_m vs.result_matrix
      puts
      vc.classifications.each do |classification|
        puts classification.map { |e| idx_to_chr(e) }.to_s
      end
      expect(vs.ranking).to eq [3, 1, 2, 0, 4] # E > A > C > B > D
    end

    it 'example 2 from wikipedia' do
      votestring = <<EOF
5=A;C;B;D
2=A;C;D;B
3=A;D;C;B
4=B;A;C;D
3=C;B;D;A
3=C;D;B;A
1=D;A;C;B
5=D;B;A;C
4=D;C;B;A
EOF
      vs = SchulzeBasic.do votestring, 4
      expect(vs.ranking).to eq [2, 0, 1, 3] # D > A > C > B
    end

    it 'example 3 from wikipedia' do
      votestring = <<EOF
3=A;B;D;E;C
5=A;D;E;B;C
1=A;D;E;C;B
2=B;A;D;E;C
2=B;D;E;C;A
4=C;A;B;D;E
6=C;B;A;D;E
2=D;B;E;C;A
5=D;E;C;A;B
EOF
      vs = SchulzeBasic.do votestring, 5
      expect(vs.ranking).to eq [3, 4, 0, 2, 1] # B > A > D > E > C
    end

    it 'example 4 from wikipedia' do
      votestring = <<EOF
3=A;B;C;D
2=D;A;B;C
2=D;B;C;A
2=C;B;D;A
EOF
      # beat matrix
      # ___|_A_|_B_|_C_|_D_|
      #  A |   | 5 | 5 | 3 |
      #  B | 4 |   | 7 | 5 |
      #  C | 4 | 2 |   | 5 |
      #  D | 6 | 4 | 4 |   |

      vs = SchulzeBasic.do votestring, 4
      vc = SchulzeClassifications.new(vs)
      expect(vs.ranking).to eq [0, 1, 0, 1] # B > C, D > A
      expect(vs.winners_array).to eq [0, 1, 0, 1] # B is potential winner, D is potential winner

      [[1, 2, 3, 0],
       [1, 3, 0, 2],
       [1, 3, 2, 0],
       [3, 0, 1, 2],
       [3, 1, 0, 2],
       [3, 1, 2, 0]].each do |array|
        expect(vc.classifications).to include array
      end
      expect(vc.classifications.size).to eq 6
      expect(vs.winners_array).to eq [0, 1, 0, 1]
      expect(vs.beat_couples).to eq [[1, 2], [3, 0]]
      expect(vs.ties).to eq [[0, 2], [1, 3]]
      expect(vc.classification_with_ties).to eq [[1, 3], [0, 2]]

      # we have more possible solutions here:
      # B > C > D > A
      # B > D > A > C
      # D > A > B > C
      # B > D > C > A
      # D > B > A > C
      # D > B > C > A
      # so the solution is B and D are preferred over A and C
    end

    # https://www.airesis.it/groups/gruppo-di-sviluppo-airesis/proposals/6051-internazionalizzazione-del-gruppo-di-sviluppo-di-airesis
    it 'example 1 from airesis' do
      votestring = <<EOF
1=C;A;D;B
1=D;C;A;B
1=C;D;A;B
1=B;D;A;C
2=A;D;C;B
EOF
      # beat matrix
      # ___|_A_|_B_|_C_|_D_|
      #  A |   | 5 | 0 | 0 |
      #  B | 0 |   | 0 | 0 |
      #  C | 0 | 5 |   | 0 |
      #  D | 0 | 5 | 4 |   |
      vs = SchulzeBasic.do votestring, 4
      vc = SchulzeClassifications.new(vs)
      expect(vs.ranking).to eq [1, 0, 1, 2]
      expect(vs.winners_array).to eq [1, 0, 0, 1]
      expect(vs.beat_couples).to eq([[0, 1], [2, 1], [3, 1], [3, 2]])
      expect(vs.ties).to eq([])
      expect(vc.classification_with_ties).to eq [[0, 3], [2], [1]]
      # D = 2, A = 1, C = 1, B = 0
      # p[A,X] >= p[X,A] for every X? YES
      # p[B,X] >= p[X,B] for every X? NO
      # p[C,X] >= p[X,B] for every X? NO
      # p[D,X] >= p[X,D] for every X? YES
    end
  end

  it 'example 2 from airesis' do
    votestring = <<EOF
F;D;G;E;A;B;C
G;E;D;A;B,C;F
F;G;D;B,E;A;C
F;D;G;E;A,B,C
B,E,F;A,C,D,G
A,B,E,G;D;C,F
A,B,C,G;D,E;F
G;E;D;F;A;C;B
C,F;B,G;A,E;D
E;A,B,C,D,F,G
B,E,G;A,F;C;D
EOF

    vs = SchulzeBasic.do votestring, 7
    expect(vs.ranking).to eq [1, 2, 0, 2, 5, 4, 6]
    expect(vs.winners_array).to eq [0, 0, 0, 0, 0, 0, 1]
  end

  it 'a single classification is possible with one tie' do
    votestring = <<EOF
74;75;76;77
76;77;75;74
76;75;77,74
75;77,76;74
74,75,76;77
74;76;75,77
74;75;77;76
74;75,76;77
77;76;74,75
75;74,76;77
74;75;76;77
76;75;77;74
74;75;76;77
74;76;77,75
EOF

    vs = SchulzeBasic.do votestring, 4
    vc = SchulzeClassifications.new(vs)
    expect(vs.ranking).to eq [3, 1, 1, 0]
    expect(vs.winners_array).to eq [1, 0, 0, 0]
    expect(vs.ties).to eq [[1, 2]]
    expect(vs.beat_couples).to eq [[0, 1], [0, 2], [0, 3], [1, 3], [2, 3]]
    expect(vc.classification_with_ties).to eq [[0], [1, 2], [3]]
  end

  it 'a classification is possible with three ties' do
    votestring = <<EOF
F,D;B,A;E,C
EOF

    vs = SchulzeBasic.do votestring, 6
    vc = SchulzeClassifications.new(vs)
    expect(vs.ranking).to eq [2, 2, 0, 4, 0, 4]
    expect(vs.winners_array).to eq [0, 0, 0, 1, 0, 1]
    expect(vs.ties).to eq [[0, 1], [2, 4], [3, 5]]
    expect(vs.beat_couples).to eq [[0, 2], [0, 4],
                                   [1, 2], [1, 4],
                                   [3, 0], [3, 1],
                                   [3, 2], [3, 4],
                                   [5, 0], [5, 1],
                                   [5, 2], [5, 4]
                                  ]
    expect(vc.classification_with_ties).to eq [[3, 5], [0, 1], [2, 4]]
  end

  describe 'from file' do
    it 'scan example4' do
      sb = SchulzeBasic.do File.open('spec/support/examples/vote4.list')
      expect(sb.ranking).to eq([0, 1, 3, 2])
    end
  end
end
