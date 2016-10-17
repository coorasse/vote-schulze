module Vote
  module Condorcet
    module Schulze
      class Classifications
        def initialize(schulze_basic)
          @schulze_basic = schulze_basic
        end

        # compute all possible solutions
        # since this can take days, there is an option to limit the number of calculated classifications
        # the default is 10. if the system is calculating more then 10 possible classifications it will stop
        # raising a TooManyClassifications exception
        # you can set it to false to disable the limit
        def classifications(limit_results = false)
          @classifications = []
          @limit_results = limit_results
          calculate_classifications
          @classifications
        end

        # compute the final classification with ties included
        # the result is an array of arrays. each position can contain one or more elements in tie
        # e.g. [[0,1], [2,3], [4], [5]]
        def classification_with_ties
          result = []
          result << @schulze_basic.potential_winners # add potential winners on first place
          result += @schulze_basic.ties.clone.sort_by { |tie| -@schulze_basic.ranking[tie[0]] } # add ties by ranking
          result.uniq! # remove duplicates (potential winners are also ties)
          add_excludeds(result)
        end

        def add_excludeds(result)
          excludeds = (@schulze_basic.candidates - result.flatten) # all remaining elements (not in tie, not winners)
          excludeds.each do |excluded|
            result.each_with_index do |position, index|
              # insert before another element if they have a better ranking
              break result.insert(index, [excluded]) if better_ranking?(excluded, position[0])
              # insert at the end if it's the last possible position
              break result.insert(-1, [excluded]) if index == result.size - 1
            end
          end
          result
        end

        private

        def better_ranking?(a, b)
          @schulze_basic.ranking[a] > @schulze_basic.ranking[b]
        end

        def rank_element(el)
          rank = 0
          rank -= 100 if @schulze_basic.potential_winners.include?(el)
          @schulze_basic.beat_couples.each do |b|
            rank -= 1 if b[0] == el
          end
          rank
        end

        def calculate_classifications
          start_list = (0..@schulze_basic.ranking.length - 1).to_a
          start_list.sort! { |e1, e2| rank_element(e1) <=> rank_element(e2) }
          compute_classifications([], @schulze_basic.potential_winners, @schulze_basic.beat_couples, start_list)
        end

        def compute_classifications(classif = [], potential_winners, beated_list, start_list)
          return compute_permutations(classif, start_list) if beated_list.empty?
          next_list = (classif.empty? && potential_winners.any?) ? potential_winners : start_list
          add_elements(beated_list, classif, next_list, start_list)
        end

        def add_elements(beated_list, classif, potential_winners, start_list)
          potential_winners.each { |element| add_element(classif, beated_list, start_list, element) }
        end

        def compute_permutations(classif, start_list)
          start_list.permutation.each do |array|
            @classifications << classif + array
            check_limits
          end
        end

        def check_limits
          fail TooManyClassificationsException if @limit_results && @classifications.size > @limit_results
        end

        def add_element(classif, beated_list, start_list, element)
          return if beated_list.any? { |c| c[1] == element }
          classification = classif.clone << element
          next_start_list = clone_and_delete(start_list, element)
          if next_start_list.empty?
            @classifications << classification
            check_limits
          else
            compute_classifications(classification, nil,
                                    beated_list.clone.delete_if { |c| c[0] == element }, next_start_list)
          end
        end

        def clone_and_delete(list, element)
          list.clone.tap { |l| l.delete(element) }
        end
      end
    end
  end
end

class TooManyClassificationsException < StandardError
end
