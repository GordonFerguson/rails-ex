class Person < ActiveRecord::Base
  has_many :credits, :dependent => :delete_all

  def self.in_lnf_order original_list
    if original_list.nil?
      []
    else
      original_list.sort_by { |person| person.lnf }
    end
  end

  # return a list of people whose name matches a pattern
  def self.names_like(search_string)
    Person.order('name').where("name like ?", "%#{search_string}%")
  end

  def credits_by_season
    rslt = credits.includes(:team => [:season])
    rslt = credits.sort { |c1, c2| my_sort_block(c1, c2) }
    rslt.group_by { |c| c.team.season }
  end

  def my_sort_block(c1, c2)
    c = c1.team.season.year <=> c2.team.season.year
    c = c2.team_type <=> c1.team_type if c.eql?(0)
    if c.eql?(0) && c1.team_type.eql?('Production')
      c = c1.production.opened_on <=> c2.production.opened_on
      c = -1 if c.nil? && c1.nil?
      c = +1 if c.nil? && c2.nil?
      c = 0 if c.nil?
    end
    c = c1.position <=> c2.position if c.eql?(0)
    c
  end

  # convert existing name to 'last name first'  format
  # todo this only works for the simple cases (no Joe Smyth, Jr, MA etc)
  def lnf
    a = name.split.rotate(-1)
    a[0] + ', ' + a.drop(1).join(' ')
  end
end

