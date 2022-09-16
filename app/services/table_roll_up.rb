module TableRollUp
  ##
  # Assumptions:
  #  * You have a table with *lots* of rows
  #  * You want to squish those rows into fewer rows, "compacting" them, generally creating
  #    a new row for each day, losing as little information as possible beyond time grandularity
  #  * You have a column, something like "counts_for", that could hold the count of rows
  #    that are being replaced
  #  * You are okay with this being idempotent -- repeatedly crunching the same rows is both
  #    taxing *and* error-prone -- in other words, this mechanisms is only for "settled" rows
  #
  # We do everything - create + delete - in one transaction, making sure we only deleting records
  # if the count of what's being deleted *exactly matches* the count we're inserting.
  #
  # @param relation [ActiveRecord::Base] an ActiveRecord-ish class that responds to a
  #                                      scope-ish interface
  # @param counter [String,Symbol] the name of the column that stores the count
  # @param rows [Enumerable] each row should be hash-like, the keys are the attributes we'll
  #                          use to create the new "squished" records
  def roll_up(relation, counter, rows, count_baseline: 1)
    counter = counter.to_s
    rows.each do |row|
      hash = (row.keys.map { |key| key == "created_on" ? "created_at" : key.to_s }.zip row.values).to_h
      hash[counter] = rows.count * count_baseline
      query = hash.except(counter, "created_at")

      relation.transaction do
        delete_me = relation.where(counter => count_baseline)
          .where("DATE(created_at) = ?", hash["created_at"])
          .where(query)

        raise ActiveRecord::Rollback unless delete_me.count == row[counter]

        delete_me.delete_all

        relation.create!(hash)
      end
    end
  end

  module_function :roll_up
end
