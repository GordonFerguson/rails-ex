class Credit < ActiveRecord::Base

  # deprecated
  belongs_to :person
  belongs_to :team, :polymorphic => true, touch: true

  # experimenting
  # belongs_to :production, foreign_key: 'team_id', conditions: "team_type = 'Production'"
  # belongs_to :season, foreign_key: 'team_id', conditions: "team_type = 'Season'"

  acts_as_list scope: [:credit_code, :team_id ], top_of_list: 0
  after_create :adjust_credit_code

  CATEGORIES = ['Costumes', 'Scenery', 'Lighting', 'Sound','Director', 'Stage Manager', 'Other', 'Unknown']
  CATEGORY_GUESSES = {
    'Staff' => [],
    'Cast' => [],
    'Playwright' => [/playwright/i],
    'Director' => [/^Director/i,/^Direction/i,/co-director/i,/assistant director/i,/associate director/i],
    'Scenery' => [/Set/i, /Scene/i, /Scenic/i],
    'Costumes' => [/Costume/i],
    'Lighting'=> [/Light/i],
    'Media' => [/Media/i,/Video/i,/Projection/i],
    'Puppets' => [/puppet/i],
    'Music' => [/Music/i,/compos/i,/song/i,/accompanist/i,/lyrics/i],
    'Sound' => [/Sound/i],
    'Voice' => [/voice/i,/vocal/i,/dialect/i, /speech/i],
    'Movement' => [/movement/i,/fight/i],
    'Choreography' => [/Choreograph/i,/dance/i],
    'Dramaturg' => [/Dramaturg/i,/Literary/i],
    'Stage Manager' => [/Stage Manag/i],
    'Casting' => [/casting/i],
    'Other' => [//],
    'Unknown' => []}

  # the categories to show an editor
  def self.category_options
    CATEGORY_GUESSES.keys-['Cast','Staff','Unknown']
  end
  # count credits by category: return a hash of category name -> count
  def self.category_summary
    result = {}
    x = CATEGORY_GUESSES.each {|k, re_list| result[k] = 0}
    result['Cast'] = Credit.where(credit_code: 'ACT').count
    result['Staff'] = Credit.where(team_type: 'Season').count
    result.merge(Credit.where(team_type: 'Production', credit_code:  [nil, '']).group(:category).count)
  end


  # count credits by category: return a hash of category name -> count
  # FIXME BROKEN
  def self.category_people_count
    result = {}
    x = CATEGORY_GUESSES.each {|k, re_list| result[k] = 0}
    result['Cast'] = Credit.where(credit_code: 'ACT').count
    result['Staff'] = Credit.where(team_type: 'Season').count
    result.merge(Credit.where(team_type: 'Production', credit_code:  '').group(:category).count)
  end

  # count credits by category: return a hash of category name -> count
  def self.category_grouping
    blanks = {}
    CATEGORIES.each {|category| blanks[category] = []}
    blanks.merge(Credit.order(:category).group_by(&:category))
  end

  def self.guess_all_categories
    Credit.all.each {|credit| credit.guess_category}
  end

  def guess_category
    # if credit_code.blank? and team_type.eql?('Production')  and category.blank?
    if category.eql?('Other')
      CATEGORY_GUESSES.each do |category, patterns|
        patterns.each do |regexp|
          if regexp.match(credit)
            update(category: category)
            return
          end
        end
      end
    end
  end



def adjust_credit_code
  update(credit_code: 'ACT') if credit.eql?('Actor')
end

def for_production?
  team_type.eql? 'Production'
end
def for_season?
  team_type.eql? 'Season'
end

def production
  if team.nil?
    nil
  elsif team_type.eql? 'Production'
    team
  else
    throw 'Polymorphic error in Credit model'
  end
end

def season
  if team.nil?
    nil
  elsif team_type.eql? 'Season'
    team
  else
    throw 'Polymorphic error in Credit model'
  end
end

def poly_name
  "#{team_type} #{team ? team.poly_name : 'error '+inspect}"
end

def credit_or_role
  credit.eql?('Actor') ? role : credit
end


# create a Credit, also create a person if needed
def self.new_with_person(credit_params)
  if credit_params[:person_id].to_i == 0
    person = Person.new(name: credit_params[:person])
    person.save # todo check that this is needed here
    credit_params[:person_id] = person.id
  end
  credit_params.delete(:person) # avoid a clash
  Credit.new(credit_params)
end

def is_actor
  credit.eql? 'Actor'
end



def self.for a_production
  it = Credit.new
  it.production = a_production
  it.credit_seq = 1
  it
end


def credit_type

end


end
