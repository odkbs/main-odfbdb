class String
  def chomps *suffixes
    suffixes.sort_by(&:length).reverse_each do |suffix|
      return chomp(suffix) if end_with?(suffix)
    end
    nil
  end
end
