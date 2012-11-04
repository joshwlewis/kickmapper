class Backer < Kickstarter

  def self.by_project_url(url, options = {})
    options[:pages] = 5
    options[:css_selector] = '.NS_backers__backing_row'
    list(File.join(url, 'backers'), options)
  end

  def name
    @name ||= node.css('h3 a').inner_html
  end

  def url
    @url ||= File.join(BASE_URL, node.css('h3 a').attribute('href').to_s.split('?').first)
  end

  def location
    @location ||= node.css('.location').text.try(:strip)
  end
end