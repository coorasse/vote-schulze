module Vote
  module Condorcet
    module Schulze
      class Basic
        attr_reader :candidates, :vote_matrix, :play_matrix, :result_matrix, :ranking, :vote_count
        attr_reader :winners_array, :potential_winners, :beat_couples, :ties

        def initialize
          @beat_couples = []
          @ties = []
        end

        # All-in-One class method to get a calculated SchulzeBasic object
        def self.do(vote_matrix, candidate_count = nil)
          instance = new
          instance.load vote_matrix, candidate_count
          instance.run
          instance
        end

        def load(vote_matrix, candidate_count = nil)
          input = if vote_matrix.is_a?(Vote::Condorcet::Schulze::Input)
                    vote_matrix
                  else
                    Vote::Condorcet::Schulze::Input.new(vote_matrix, candidate_count)
                  end
          @vote_matrix = input.matrix
          @candidate_count = input.candidates
          @candidates = (0..@candidate_count - 1).to_a
          @vote_count = input.voters
          self
        end

        def run
          play
          result
          calculate_winners
          rank
          calculate_beat_couples
          calculate_potential_winners
        end

        private

        def play
          @play_matrix = build_play_matrix
          find_matches_with_wins
          find_strongest_paths
        end

        def build_play_matrix
          ::Matrix.scalar(@candidate_count, 0).extend(Vote::Matrix)
        end

        def find_matches_with_wins
          @candidate_count.times do |i|
            @candidate_count.times do |j|
              next if i == j
              if @vote_matrix[i, j] > @vote_matrix[j, i]
                @play_matrix[i, j] = @vote_matrix[i, j]
              else
                @play_matrix[i, j] = 0
              end
            end
          end
        end

        def find_strongest_paths
          @candidate_count.times do |i|
            @candidate_count.times do |j|
              next if i == j
              @candidate_count.times do |k|
                next if (i == k) || (j == k)
                @play_matrix[j, k] = [@play_matrix[j, k], [@play_matrix[j, i], @play_matrix[i, k]].min].max
              end
            end
          end
        end

        def result
          @result_matrix = ::Matrix.scalar(@candidate_count, 0).extend(Vote::Matrix)
          @result_matrix.each_with_index do |e, x, y|
            next if x == y
            @result_matrix[x, y] = e + 1 if @play_matrix[x, y] > @play_matrix[y, x]
          end
        end

        def calculate_winners
          @winners_array = Array.new(@candidate_count, 0)
          @winners_array.each_with_index do |_el, idx|
            row = @play_matrix.row(idx)
            column = @play_matrix.column(idx)
            if row.each_with_index.all? { |r, index| r >= column[index] }
              @winners_array[idx] = 1
            end
          end
        end

        def rank
          @ranking = @result_matrix.row_vectors.map { |rm| rm.inject(0) { |a, e| a + e } }
        end

        # you should call calculate_winners first
        def calculate_potential_winners
          @potential_winners ||= winners_array.map.with_index { |val, idx| idx if val > 0 }.compact
        end

        # calculates @beat_couples and @ties in roder to display results afterward
        def calculate_beat_couples
          return if @calculated_beat_couples

          ranking.each_with_index do |_val, idx|
            ranking.each_with_index do |_val2, idx2|
              next if idx == idx2
              next @beat_couples << [idx, idx2] if play_matrix[idx, idx2] > play_matrix[idx2, idx]
              calculate_ties(idx, idx2)
            end
          end
          @calculated_beat_couples = true
        end

        def calculate_ties(idx, idx2)
          return unless in_tie?(idx, idx2)
          return if @ties.any? { |tie| ([idx, idx2] - tie).empty? }
          found_tie = tie_by_idx(idx)
          return found_tie << idx2 if found_tie
          found_tie = tie_by_idx(idx2)
          return found_tie << idx if found_tie
          @ties << [idx, idx2]
        end

        def tie_by_idx(idx)
          @ties.find { |tie| tie.any? { |el| el == idx } }
        end

        def in_tie?(idx, idx2)
          @play_matrix[idx, idx2] == @play_matrix[idx2, idx] &&
            @ranking[idx] == @ranking[idx2] &&
            @winners_array[idx] == @winners_array[idx2]
        end
      end
    end
  end
end
