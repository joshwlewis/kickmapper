class Kickstarter
  BASE_URL = "http://kickstarter.com"
  attr_reader :node
  attr_accessor :document
  
  def self.list(url, options = {} )
    pages = options.fetch(:pages, 0)
    pages -= 1 unless pages == 0 || pages == :all

    start_page = options.fetch(:page, 1)
    end_page   = pages == :all ? 10000 : start_page + pages

    results = []

    params = options[:params] || {}
    (start_page..end_page).each do |page|
      retries = 0
      params[:page]=page
      Rails.logger.info "Processing #{url} page #{page}"
      url_with_params = url + "?" + params.map{|k,v| "#{k}=#{v}"}.join('&')
      begin
        doc = Nokogiri::HTML(open url_with_params)
        nodes = doc.css(options[:css_selector])
        break if nodes.empty?

        nodes.each do |node|
          results << self.new(node: node)
        end
      rescue
        retries += 1
        sleep 5
        if retries < 3
          Rails.logger.warn "Retrying #{url} (#{retries})"
          retry
        end
      end
      sleep 2
    end
    results
  end

  def initialize(options)
    @node = options[:node]
    @url = options[:url]
    load_document if node.blank?
  end

  def load_document
    @document = Nokogiri::HTML(open url)
  end
end