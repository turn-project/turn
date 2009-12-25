# Borrowed methods from Ruby Facets.

class String

  # Aligns each line n spaces.
  def tab(n)
    gsub(/^ */, ' ' * n)
  end

  # Preserves relative tabbing.
  # The first non-empty line ends up with n spaces before nonspace.
  def tabto(n)
    if self =~ /^( *)\S/
      indent(n - $1.length)
    else
      self
    end
  end

  # Indent left or right by n spaces.
  # (This used to be called #tab and aliased as #indent.)
  def indent(n, c=' ')
    if n >= 0
      gsub(/^/, c * n)
    else
      gsub(/^#{Regexp.escape(c)}{0,#{-n}}/, "")
    end
  end

end

