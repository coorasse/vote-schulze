module Vote
  module Condorcet
    module Schulze
      class Input
        def initialize(vote_list, candidate_count = nil)
          @vote_list = vote_list
          @candidate_count = candidate_count

          if @candidate_count.nil?
            insert_vote_file(@vote_list) if vote_list.is_a?(File)

          else
            @vote_matrix = ::Matrix.scalar(@candidate_count, 0).extend(Vote::Matrix)
            insert_vote_array(@vote_list) if vote_list.is_a?(Array)
            insert_vote_strings(@vote_list) if vote_list.is_a?(String)
          end
        end

        def insert_vote_array(va)
          va.each do |vote|
            @vote_matrix.each_with_index do |_e, x, y|
              next if x == y
              @vote_matrix[x, y] += 1 if vote[x] > vote[y]
            end
          end
          @vote_count = va.size
        end

        def insert_vote_strings(vs)
          vote_array = []

          vs.split(/\n|\n\r|\r/).each do |voter|
            voter = voter.split(/=/)
            vcount = (voter.size == 1) ? 1 : voter[0].to_i

            vcount.times do
              tmp = voter.last.split(/;/)
              vote_array << extract_vote_string(tmp)
            end
          end

          insert_vote_array vote_array
        end

        def extract_vote_string(tmp)  # array of preferences  [['1, 2'], ['3']. ['4, 5']]
          tmp2 = []
          order_and_remap(tmp).
            map do |e| # find equal-weighted candidates
            if e[0].size > 1
              e[0].split(/,/).each { |f| tmp2 << [f, e[1]] }
            else
              tmp2 << e
            end
          end
          tmp2.sort.map { |e| e[1] } # order, strip & add
        end

        def order_and_remap(tmp)
          tmp.map { |e| [e, @candidate_count - tmp.index(e)] }
        end

        def insert_vote_file(vf)
          vf.rewind
          @candidate_count = vf.first.strip.to_i # reads first line for count
          @vote_matrix = ::Matrix.scalar(@candidate_count, 0).extend(Vote::Matrix)
          insert_vote_strings vf.read # reads rest of file (w/o line 1)
          vf.close
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
