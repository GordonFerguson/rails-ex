class Season < ActiveRecord::Base
  has_many :productions, -> { order(:opened_on) }
  has_many :credits, -> { order 'position' }, :as => :team
  belongs_to :season # dummy for poly join
  include Compactness

def staff
  credits
end

# test that a date is in the season
def includes_date?(date)
  return false if date.nil?
  start_date = Date.new(year.to_i,8,1)
  end_date =   Date.new(year2.to_i,7,1)
  date >= start_date && date <= end_date
end

def self.year(year)
  Season.find_by(year: year)
end

def self.for_years(from, thru)
  # Season.where('year > ? and year <= ?')
  if from.blank?
    from = '1950'
    thru = '2050'
  end
  thru = from if thru.blank?
  Season.where(:year => from..thru).includes(:productions).order(:year)
end

# return  an alpha list of all the people with credits in this season
# no duplicates
def self.people(season_id)
  production_prefetch = Season.where(id: season_id).includes(:productions=>[:credits=>[:person]])
  unsorted_people = Season.people_in_productions(production_prefetch)

  staff_prefetch = Season.where(id: season_id).includes(:credits=>[:person])
  unsorted_staff =Season.people_on_staff(staff_prefetch)
  unsorted_people.concat(unsorted_staff)
  Person.in_lnf_order(unsorted_people.uniq)
end

  def self.people_in_productions(seasons)
    seasons.collect{|season|season.productions}.flatten
      .collect{|production| production.credits}.flatten
      .collect{|credit| credit.person}
      .uniq # eliminate duplicates
  end
  def self.people_on_staff(seasons)
    seasons.collect{|season|season.staff}.flatten
      .collect{|credit| credit.person}
      .uniq # eliminate duplicates
  end
# ############# one time creation from existing productions
  def self.build_from_productions
    x = Production.all
    x.each do |production|
      year = production.temp_year
      season = Season.find_or_create_by(:year => year)
      production.season = season
      production.save
      puts "-- #{production.title}"
    end
  end

  def poly_name
    "#{year}-#{year2} Season."
  end

  def title
    "Season #{year}-#{year2}"
  end

  def years
    "#{year}-#{year2}"
  end


  def season
    # for poly
    self
  end

  # return true iff the postions are compact, ie 0,1,2...,n: no gaps
  def positions_compact?
    # note the awkward negative test here, what's the opposite of detect?
    credits.each_with_index.detect { |credit, index| !credit.position.eql?(index) }.nil?
  end
end
