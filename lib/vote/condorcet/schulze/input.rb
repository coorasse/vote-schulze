module Vote
  module Condorcet
    module Schulze
      class Input
        def initialize(vote_list, candidate_count = nil)
          @vote_list = vote_list
          @candidate_count = candidate_count
          @candidates_abc = []
          if @candidate_count.nil?
            insert_vote_file(@vote_list) if vote_list.is_a?(File)
          else
            @vote_matrix = ::Matrix.scalar(@candidate_count, 0).extend(Vote::Matrix)
            insert_vote_array(@vote_list) if vote_list.is_a?(Array)
            insert_vote_strings(@vote_list) if vote_list.is_a?(String)
          end
        end

        def insert_vote_array(vote_array)
          vote_array.each do |vote|
            @vote_matrix.each_with_index do |_e, x, y|
              next if x == y
              @vote_matrix[x, y] += 1 if vote[x] && vote[y] && vote[x] > vote[y]
            end
          end
          @vote_count = vote_array.size
        end

        def insert_vote_strings(vote_strings)
          vote_array = []

          vote_strings.split(/\n|\n\r|\r/).each do |voter|
            voter = voter.split(/=/)
            vcount = (voter.size == 1) ? 1 : voter[0].to_i
            vcount.times do
              tmp = voter.last.split(/;/)
              vote_array << extract_vote_string(tmp)
            end
          end
          insert_vote_array vote_array
        end

        def extract_vote_string(tmp) # array of preferences  [['1, 2'], ['3']. ['4, 5']]
          tmp2 = flatten_votes(order_and_remap(tmp))
          tmp2.map! { |e| [e[0].to_i, e[1]] } if all_numbers?(tmp2)
          tmp2.sort.map { |e| e[1] } # order, strip & add
        end

        def flatten_votes(votes)
          tmp2 = []
          votes.map do |e| # find equal-weighted candidates
            (e[0].size > 1) ? e[0].split(/,/).each { |f| tmp2 << [f, e[1]] } : tmp2 << e
          end
          tmp2
        end

        def all_numbers?(array)
          array.map { |e| e[0] }.all? { |el| /\A\d+\z/.match(el) }
        end

        def order_and_remap(tmp)
          tmp.map { |e| [e, @candidate_count - tmp.index(e)] }
        end

        def insert_vote_file(vote_file)
          vote_file.rewind
          @candidate_count = vote_file.first.strip.to_i # reads first line for count
          @vote_matrix = ::Matrix.scalar(@candidate_count, 0).extend(Vote::Matrix)
          insert_vote_strings vote_file.read # reads rest of file (w/o line 1)
          vote_file.close
        end

        def matrix
          @vote_matrix
        end

        def candidates
          @candidate_count
        end

        def voters
          @vote_count
        end
      end
    end
  end
end
