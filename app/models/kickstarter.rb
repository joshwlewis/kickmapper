class Kickstarter
  BASE_URL = "http://kickstarter.com"
  attr_reader :node
  
  def self.list(url, options = {} )
    pages = options.fetch(:pages, 0)
    pages -= 1 unless pages == 0 || pages == :all

    start_page = options.fetch(:page, 1)
    end_page   = pages == :all ? 10000 : start_page + pages

    results = []

    puts "start: #{start_page}"
    puts "end: #{end_page}"
    params = options[:params] || {}
    (start_page..end_page).each do |page|
      retries = 0
      params[:page]=page
      url_with_params = url + "?" + params.map{|k,v| "#{k}=#{v}"}.join('&')
      begin
        doc = Nokogiri::HTML(open url_with_params)
        nodes = doc.css(options[:css_selector])
        break if nodes.empty?

        nodes.each do |node|
          results << self.new(node)
        end
      rescue Timeout::Error
        retries += 1
        retry if retries < 3
      end
    end
    results
  end

  def initialize(node)
    @node = node
  end
end