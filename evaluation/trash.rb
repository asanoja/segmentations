def dameraulevenshtein(seq1, seq2)
    oneago = nil
    thisrow = (1..seq2.size).to_a + [0]
    seq1.size.times do |x|
        twoago, oneago, thisrow = oneago, thisrow, [0] * seq2.size + [x + 1]
        seq2.size.times do |y|
            delcost = oneago[y] + 1
            addcost = thisrow[y - 1] + 1
            subcost = oneago[y - 1] + ((seq1[x] != seq2[y]) ? 1 : 0)
            thisrow[y] = [delcost, addcost, subcost].min
            if (x > 0 and y > 0 and seq1[x] == seq2[y-1] and seq1[x-1] == seq2[y] and seq1[x] != seq2[y])
                thisrow[y] = [thisrow[y], twoago[y-2] + 1].min
            end
        end
    end
    return thisrow[seq2.size - 1]
end
