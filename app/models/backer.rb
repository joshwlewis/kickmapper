class Backer < Kickstarter

  def self.by_project_url(url, options = {})
    options[:pages] = :all
    options[:css_selector] = '.NS_backers__backing_row'
    list(File.join(url, 'backers'), options)
  end

  def name
    @name ||= node.css('h3 a').inner_html
  end

  def url
    @url ||= File.join(BASE_URL, node.css('h3 a').attribute('href').to_s.split('?').first)
  end

  def location_name
    @location_name ||= node.css('.location').text.try(:strip)
  end

  def location
    @location = location_name.present? ? Location.find_or_create_by_address(location_name) : nil
  end

end