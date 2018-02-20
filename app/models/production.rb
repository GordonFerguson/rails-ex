class Production < ActiveRecord::Base
  belongs_to :season
# TODO some validation -
  has_many :credits, -> { order 'position' }, :as => :team

# todo scopes for cast and creatives (not cast)

  FLIPPED_PREFIXES = %w(The An A La Le Un)

  def cast_list
    credits.select { |e| e.is_actor }
  end

# test that opening and closing dates are consistent with the Season years
# fail if there is no opening date, allow no closing date
def dates_in_season?
  return false if opened_on.nil?
  return true
  return false unless season.includes_date?(opened_on)
  return true if closed_on.nil?
  season.includes_date?(closed_on)
end

# make the postions compact, preserve the exiting order
  def compact_cast
    Production.transaction do
      cast_list.each_with_index do |credit, index|
        credit.position = index
        credit.save
      end
    end
  end

# return a list of productions whose title matches a pattern
# include seasons and sort by season year
def self.titles_like(search_string)
  Production.where("title like ?", "%#{search_string}%").includes(:season).order('seasons.year')
end

  # return true iff the cast's postions are compact, ie 0,1,2...,n: no gaps
  def cast_compact?
    # note the awkward negative test here, what's the opposite of detect?
    cast_list.each_with_index.detect { |credit, index| !credit.position.eql?(index) }.nil?
  end

  # return true iff the cast's postions are compact, ie 0,1,2...,n: no gaps
  def creatives_compact?
    # note the awkward negative test here, what's the opposite of detect?
    creatives.each_with_index.detect { |credit, index| !credit.position.eql?(index) }.nil?
  end

  def compact_creatives
    Production.transaction do
      creatives.each_with_index do |credit, index|
        credit.position = index
        credit.save
      end
    end
  end

  def poly_name
    "#{title}"
  end
  def dated_title
    "#{title} #{season.title}"
  end

  def year
    season.year
  end

  def creatives
    credits.reject { |e| e.is_actor }
  end

# Class side utility to
# Convert, eg, 'Weird Title, The' to 'The Weird Title'
# Rules: 
#     preserve up/low case of prefix; 
#     accept "foo,    A" with extra white space but return "A foo" with just the one space.
#     strip white space from the result
#     a sequence like Little,A is not flipped (needs to have some white space eg 'Little, A'
# see test/jpr/pner_flip_test for some gories
  def self.flip_prefix str
    FLIPPED_PREFIXES.each do |pfix|
      if (str =~ /,\s+(#{pfix})\s*$/i) # comma, space, prefix, space, end (ignore case)
        r = $1 +' '+ $` # the 1st group, space,  the bit before the comma
        return r.strip
      end # if
    end # do
    return str.strip
  end

#Return the title flipped but with tex intact
  def flipped_title
    return '' if title.nil?
    self.class.flip_prefix title.strip
  end

# return all the credits of a given type (sets S, costumes D, lights L)
  def credits_of_type type_code
    credits.select { |c| c.credit_code.eql? type_code }
  end


# return a list of productions whose title matches a pattern
  def self.names_like search_string
    Production.where("title like ?", "%#{search_string}%").order('title, year')
  end

# one off parsing of a production list
# lines are one of
#  blank
#  season: 1974 -  1975 more info
#   1975-1976 Prequel Tom Haas
#  production
#   Long Day’s Journey into Night

  def self.parse_txt_list filename
    current_season = 0
    File.open(filename, "r") do |f|
      f.each_line do |line|
        if line.blank?
          # do nothing
        else
          if /^(\d{4})-\d{4}/.match(line)
            current_season = $1.to_i
            puts "***SEASON-#{$1}: " + line
          else
            if current_season.eql?(0)
              puts 'ignore funny stuff at front of file'
            else
              puts "sTITLE " + line
              p = Production.new(:title => line.to_s, :season => current_season, :note => 'parsed')
              if !p.save
                puts "************* save failed for #{line} in #{current_season}"
              end
            end
          end
        end
      end
    end
  end
end
