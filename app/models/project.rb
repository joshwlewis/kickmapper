# Thanks to @redronin for initial kickstarter scraping work github.com/redronin/kickstarter
# Project can be initialized by using one of the Project.by_foo methods, or rather by just initializing with a project url: Project.new(url: 'http://www.kickstarter.com/ouya/ouya-a-new-kind-of-console')
class Project < Kickstarter

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

  def self.list(path, options={})
    options[:css_selector] = '.project'
    super(path, options)
  end

  def slug
    @slug ||= url.split('/projects/').last
  end
  
  def name
    @name ||= (document ? document.css('#title a') : link).text.strip
  end
  
  def description
    @description ||= (document ? document.css('.short-blurb') : node.css('h2 + p')).text.strip
  end
  
  def url
    @url ||= File.join(BASE_URL, link.attribute('href').to_s.split('?').first)
  end
  
  def owner
    @owner ||= (document ? document.css('#subtitle a') : node.css('h2 span').first).text.gsub(/by\s/i, "").strip
  end
  
  def image_url
    @image_url ||= (document ? document.css('#main img') : node.css('.project-thumbnail img')).first.attribute('src').to_s
  end

  def backers
    Backer.by_project_url(url)
  end

  def to_hash
    { name: name, slug: slug, url: url, description: description, owner: owner }
  end

  def inspect
    to_hash.inspect
  end

  def link
    node.css('h2 a').first
  end

end