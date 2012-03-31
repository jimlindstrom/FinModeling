module FinModeling

  module CanCacheClassifications
    protected

    def lookup_cached_classifications(base_filename, rows)
      filename = rows_to_filename(base_filename, rows)
      return false if !File.exists?(filename) || !Config.caching_enabled?

      f = File.open(filename, "r")
      rows.each do |row|
        row.type = f.gets.chomp.to_sym
      end
      f.close
      return true
    end

    def save_cached_classifications(base_filename, rows)
      filename = rows_to_filename(base_filename, rows)
      f = File.open(filename, "w")
      rows.each do |row|
        f.puts row.type.to_s
      end
      f.close
    end

    private

    def rows_to_filename(base_filename, rows)
      unique_str = Digest::SHA1.hexdigest(rows.map{ |row| row.key }.join)
      filename = base_filename + unique_str + ".txt"
    end
  end

end
