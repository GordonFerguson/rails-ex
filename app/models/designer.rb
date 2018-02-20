class Designer < ActiveRecord::Base
  #PARSER = Detexp.new
  DEFAULT_PROOF_DATE = DateTime.parse('1995-01-01')
  CONDITIONS = ['New', 'In Progress', 'In Review', 'Printable']
  REVIEW_STATUS_CODES = %w(None Todo Sent Recd Done)
  GRADES = %w(A B C D Inc)
  INITIAL_CONDITION = 'New'
  has_many :credits, :dependent => :delete_all
  has_many :citations, :dependent => :delete_all
  has_many(:comments ,->{where.not(state: 'deletable') }, :dependent => :delete_all )
  # has_many :productions, ->{uniq.order('productions.year') }, :through => :credits
  has_many :file_resources, -> {order ' lower(label)'},:dependent => :delete_all

  #hmm see
  # http://stackoverflow.com/questions/328525/what-is-the-best-way-to-set-default-values-in-activerecord
  after_initialize :set_defaults

  def credits_by_seasonbkup
    # x = {'lump'}
    # x = credits.includes(:team => [:season])
    # x = credits.includes(:team => [:season]).group_by{|c| c.team.season}
    x = credits.includes(:team => [:season]).order('team_type desc').group_by{|c| c.team.season}
    # puts 'here'
    # credits.includes(:team,)
    x
  end

  def credits_by_season
    x = credits.includes(:team => [:season])
    x = credits.sort{|c1, c2| my_sort_block(c1, c2)}
    x.group_by{|c| c.team.season}

    # x.group_by{|c| c.team.season}
    # x
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
  def self.in_lnf_order original_list
      original_list.sort_by{|des| des.lnf}

  end

  #fixme this should use the (new) Designers.designer_number column to
  # improve robustness in the face of db moves etc
  def image_dir
    'D'+id.to_s
  end

  def set_defaults
    # self.proofed_on = DEFAULT_PROOF_DATE
    # self.condition ||= INITIAL_CONDITION
  end

  #return citations which are public
  # todo use scopes to clean this up
  def public_citations
    citations.select {|c|c.status.eql? 'Public'}
  end

  #return citations which are not deleted
  # todo use scopes to clean this up
  def extant_citations
    citations.select {|c|! c.status.eql? 'Deleted'}
  end



  # return a designers credits sorted by year, title (of production), code and seq (of credit)
  def sorted_credits
    credits.includes(:productions).order('productions.year, productions.title, credit_code, credit_seq')
  end

    # return the status codes used for 'external review' and 'designer review'
    # @deprecated use the constant directly
    def self.review_codes
      return REVIEW_STATUS_CODES
    end


  # return all the designers in the order used by BDR
  def self.book_order
    Designer.order('name').includes(:credits, :productions)
  end

  # Return a list of all designers who have been edited since they were proofed;
  #  ie proofed_on date preceeds the updated_at date
  def self.unproofed
    Designer.where('proofed_on < updated_at').order('name')
  end

  # return a list of designers whose name matches a string
  # todo: any uses of this (since I added names_like)
  # @deprecated use names_like
  def self.names_matching search_string
    names_like search_string
  end

  # return a list of designers whose name matches a pattern
  def self.names_like search_string
    Designer.order('name').where("name like ?", "%#{search_string}%")
  end

  # Return a list of all designers whose bio matches a given string
  def self.bios_matching search_string
    Designer.order('name').where("bio like ?", "%#{search_string}%")
  end

  # Return a list of all designers who have have comments (submitted or read)
  # be sure to get only unique hits here
  def self.with_comments
    Designer.joins(:comments).where("comments.state = 'Submitted' OR comments.state ='Read'").order('name').uniq
  end

  # Return a list of all designers who have have unread comments (i.e. submitted only)
  # be sure to get only unique hits here
  def self.with_unread_comments
    Designer.joins(:comments).where("comments.state = 'Submitted'").order('name').uniq
  end


  #Return the name in a nice human readable HTML-ish string.
  # TODO track down the errant leading space so I don't need strips
  def display_name
    s=if name_with_markup && !name_with_markup.empty? then
      name_with_markup
    else
      n = name.nil? ? '' : name;
      invert_name(n)
    end
    s.strip.html_safe
  end

  # return the credits grouped by production (list of lists)
  # @deprecated the view now just gets the productions for the designer etc
  def grouped_credits
    groups = []
    curr_production = nil
    curr_group = nil
    #for credit in credits
    for credit in sorted_credits
      if credit.production == curr_production
        curr_group << credit
      else
        curr_group = [credit]
        groups << curr_group
        curr_production = credit.production
      end
    end
    groups
  end

    # return all the designer's credits of a given type (sets S, costumes D, lights L)
    def credits_of_type(type_code)
      credits.select do |c|
        c.credit_code.eql? type_code
      end
    end

    # return all the 'unresolved' comments
    # impl note -- there are only a few, so do this in memory
    def unresolved_comments
      comments.select {|cmt| cmt.unresolved?}
    end

    # return comments (optionally filtered to unresolved ones)
    def filtered_comments(states_to_show=false)
      # todo fancify the selection
      if states_to_show.blank?
        comments
      else
        comments.select { |c| states_to_show.include? c.state }
      end
    end



  # count flags and return a hash
  def self.flag_counts
    rtn = Hash.new(0)
    arr = %w(is_attn_required is_tech_issue is_high_priority)
    arr.each do |a|
      sql = "SELECT COUNT(*) FROM designers where #{a} = true"
      # which is a hash  'COUNT(*)=>n'
      r = ActiveRecord::Base.connection.select_one(sql)
      rtn[a] = r['COUNT(*)']
    end
    rtn
  end

  # return the relation
  def self.condition_set array_of_conditions
    #attr_list = array_of_conditions.map{|e| "condition = #{e}"}.join(' OR ')
    Designer.where(:condition => array_of_conditions).order('condition, name')
  end

  # return any comments (in submitted state i.e. unread) by a given user
  # Could optimize with sql I guess but I expect few comments per designer
  def comments_by(a_user)
    comments.select { |cmt| cmt.user == a_user && cmt.state.eql?(Comment::SUBMITTED_STATE) }
  end

  # convert existing name to 'last name first'  format
  # todo this only works for the simple cases (no Joe Smyth, Jr, MA etc)
  def lnf
    a = name.split.rotate(-1)
    a[0] + ', ' + a.drop(1).join(' ')
  end

  # invert last, first to 'first last'
  def invert_name (orig_str)
    idx = orig_str.rindex(',')
    if idx
      orig_str[(idx+1)..-1] +' '+ orig_str[0..idx-1]
    else
      orig_str
    end
  end

  # Report unbalanced braces in a string to STDOUT: used for designer bios
  # return true iff there are no problems
  # @deprecated this was part of the TeX solution
  def check_braces
    depth = 0
    pos = 0
    if bio.nil?
      puts "Note: nil bio for designer id #{name} "
      return true
    end
    bio.each do |c|
      depth += 1 if c.eql?"\{"
      if c.eql? "\}"
        if depth <= 0
          puts "Unmatched closing brace in #{name} at position #{pos}"
          return false
        else
          depth -= 1
      end # if/else negative depth
      end # if close brace
    end # each character c
     if depth > 0
       puts "#{depth} Unclosed brace(s) in #{name}"
       return false
     end #if
     true
  end # check_braces

  # convert the TeX ish markup we used in the book into html.
  # This uses a racc based parser
  # see the detex (eclipse) project to build the parser class using racc
  # @obsolete : tex is not used anymore
  def self.de_tex str
    #PARSER.parse(str) rescue 'TEX  ERROR '+str
    str
  end

  # @deprecated tex is being phased out
  def bio_tex_2_html
    bio.blank? ? '' : Designer::de_tex(bio)
  end

  def bio_texy?
    ! bio.eql? bio_tex_2_html
  end

  def name_texy?
    not_texy = name_with_markup.blank? || Designer::de_tex(name_with_markup).eql?(name_with_markup)
    #not_texy = name_with_markup.blank?
    ! not_texy
  end

  def purge_texy_name
    if name_texy?
      self.texy_name = name_with_markup
      self.name_with_markup = Designer::de_tex(name_with_markup)
      save
    end
  end

  def restore_texy_name
    unless texy_name.blank?
      self.name_with_markup = texy_name
      self.texy_name = ''
    end
  end


  def purge_texy_bio
    if bio_texy?
      self.texy_bio = bio
      self.bio = bio_tex_2_html
      save
    end
  end

  def restore_texy_bio
    unless texy_bio.blank?
      self.bio = texy_bio
      self.texy_bio = ''
    end
  end
end
