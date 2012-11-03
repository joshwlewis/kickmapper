# Thanks to @redronin for initial kickstarter scraping work github.com/redronin/kickstarter

class Project
  BASE_URL = "http://kickstarter.com"  
  attr_reader :node

  Categories = {
    :art         => "art",
    :comics      => "comics",
    :dance       => "dance",
    :design      => "design",
    :fashion     => "fashion",
    :film_video  => "film%20&%20video",
    :food        => "food",
    :games       => "games",
    :music       => "music",
    :photography => "photography",
    :technology  => "technology",
    :theatre     => "theater",
    :writing     => "writing%20&%20publishing"
  }
  
  Type = {
    :recommended => 'recommended', 
    :popular     => 'popular', 
    :successful  => 'successful'
  }
  
  Lists = {
    :recommended       => "recommended",
    :popular           => "popular",
    :recently_launched => "recently-launched",
    :ending_soon       => "ending-soon",
    :small_projects    => "small-projects",
    :most_funded       => "most-funded",
    :curated           => "curated-pages",
  }
  
  def self.search(keyword, options = {})
    path = File.join(BASE_URL, 'projects', "search")
    options[:params] ||= {}
    options[:params][:term] = keyword
    list path, options
  end

  # by category
  # /discover/categories/:category/:subcategories 
  #  :type # => [recommended, popular, successful]
  def self.by_category(category, options = {})
    path = File.join(BASE_URL, 'discover/categories', Categories[category.to_sym], Type[options[:type] || :popular])
    list(path, options)
  end
  
  # by lists
  # /discover/:list
  def self.by_list(list, options = {})
    path = File.join(BASE_URL, 'discover', Lists[list.to_sym])
    list(path, options)
  end
    
  def initialize(node)
    @node = node
  end

  def handle
    @handle ||= url.split('/projects/').last
  end
  
  def name
    @name ||= link.inner_html
  end
  
  def description
    @description ||= node.css('h2 + p').inner_html
  end
  
  def url
    @url ||= File.join(BASE_URL, link.attribute('href').to_s.split('?').first)
  end
  
  
  def owner
    @owner ||= node.css('h2 span').first.inner_html.gsub(/by/, "").strip
  end
  
  def email
  end
  
  def thumbnail_url
    @thumbnail_url ||= node.css('.project-thumbnail img').first.attribute('src').to_s
  end
  
  def pledge_amount
    @pledge_amount ||= node.css('.project-stats li')[1].css('strong').inner_html.gsub(/[^\d]/,'').to_i
  end
  
  def pledge_percent
    @pledge_percent ||= node.css('.project-stats li strong').inner_html.gsub(/\,/,"").to_i
  end

  # can be X days|hours left
  # or <strong>FUNDED</strong> Aug 12, 2011
  def pledge_deadline
    @pledge_deadline ||= begin
      date = node.css('.project-stats li').last.inner_html.to_s
      if date =~ /Funded/
        Date.parse date.split('<strong>Funded</strong>').last.strip
      elsif date =~ /hours left/
        future = Time.now + date.match(/\d+/)[0].to_i * 60*60
        Date.parse(future.to_s)
      elsif date =~ /days left/
        Date.parse(Time.now.to_s) + date.match(/\d+/)[0].to_i
      end
    end
  end
  

  def to_hash
    {
      :name            => name,
      :handle          => handle,
      :url             => url,
      :description     => description,
      :owner           => owner,
      :pledge_amount   => pledge_amount,
      :pledge_percent  => pledge_percent,
      :pledge_deadline => pledge_deadline,
      :thumbnail_url   => thumbnail_url
    }
  end

  def inspect
    to_hash.inspect
  end
  
  private
  
  def self.list(url, options = {})
    pages = options.fetch(:pages, 0)
    pages -= 1 unless pages == 0 || pages == :all

    start_page = options.fetch(:page, 1)
    end_page   = pages == :all ? 10000 : start_page + pages

    results = []

    params = options[:params]
    (start_page..end_page).each do |page|
      retries = 0
      params[:page]=page
      url_with_params = url + "?" + params.map{|k,v| "#{k}=#{v}"}.join('&')
      begin
        doc = Nokogiri::HTML(open url_with_params)
        nodes = doc.css('.project')
        break if nodes.empty?

        nodes.each do |node|
          results << Project.new(node)
        end
      rescue Timeout::Error
        retries += 1
        retry if retries < 3
      end
    end
    results
  end

  def link
    node.css('h2 a').first
  end

end