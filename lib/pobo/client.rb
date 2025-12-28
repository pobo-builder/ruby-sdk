# frozen_string_literal: true

require "faraday"
require "json"

module Pobo
  class Client
    DEFAULT_BASE_URL = "https://api.pobo.space"
    MAX_BULK_ITEMS = 100
    DEFAULT_TIMEOUT = 30

    attr_reader :api_token, :base_url, :timeout

    def initialize(api_token:, base_url: DEFAULT_BASE_URL, timeout: DEFAULT_TIMEOUT)
      @api_token = api_token
      @base_url = base_url
      @timeout = timeout
    end

    # Import methods

    def import_products(products)
      validate_bulk_size!(products)
      payload = products.map { |p| p.respond_to?(:to_hash) ? p.to_hash : p }
      response = request(:post, "/api/v2/rest/products", payload)
      DTO::ImportResult.from_hash(response)
    end

    def import_categories(categories)
      validate_bulk_size!(categories)
      payload = categories.map { |c| c.respond_to?(:to_hash) ? c.to_hash : c }
      response = request(:post, "/api/v2/rest/categories", payload)
      DTO::ImportResult.from_hash(response)
    end

    def import_parameters(parameters)
      validate_bulk_size!(parameters)
      payload = parameters.map { |p| p.respond_to?(:to_hash) ? p.to_hash : p }
      response = request(:post, "/api/v2/rest/parameters", payload)
      DTO::ImportResult.from_hash(response)
    end

    def import_blogs(blogs)
      validate_bulk_size!(blogs)
      payload = blogs.map { |b| b.respond_to?(:to_hash) ? b.to_hash : b }
      response = request(:post, "/api/v2/rest/blogs", payload)
      DTO::ImportResult.from_hash(response)
    end

    # Export methods

    def get_products(page: nil, per_page: nil, last_update_from: nil, is_edited: nil)
      query = build_query_params(page, per_page, last_update_from, is_edited)
      response = request(:get, "/api/v2/rest/products#{query}")
      DTO::PaginatedResponse.from_hash(response, DTO::Product)
    end

    def get_categories(page: nil, per_page: nil, last_update_from: nil, is_edited: nil)
      query = build_query_params(page, per_page, last_update_from, is_edited)
      response = request(:get, "/api/v2/rest/categories#{query}")
      DTO::PaginatedResponse.from_hash(response, DTO::Category)
    end

    def get_blogs(page: nil, per_page: nil, last_update_from: nil, is_edited: nil)
      query = build_query_params(page, per_page, last_update_from, is_edited)
      response = request(:get, "/api/v2/rest/blogs#{query}")
      DTO::PaginatedResponse.from_hash(response, DTO::Blog)
    end

    # Iterator methods

    def each_product(last_update_from: nil, is_edited: nil, &block)
      return enum_for(:each_product, last_update_from: last_update_from, is_edited: is_edited) unless block_given?

      page = 1
      loop do
        response = get_products(page: page, per_page: MAX_BULK_ITEMS, last_update_from: last_update_from, is_edited: is_edited)
        response.data.each(&block)
        break unless response.more_pages?

        page += 1
      end
    end

    def each_category(last_update_from: nil, is_edited: nil, &block)
      return enum_for(:each_category, last_update_from: last_update_from, is_edited: is_edited) unless block_given?

      page = 1
      loop do
        response = get_categories(page: page, per_page: MAX_BULK_ITEMS, last_update_from: last_update_from, is_edited: is_edited)
        response.data.each(&block)
        break unless response.more_pages?

        page += 1
      end
    end

    def each_blog(last_update_from: nil, is_edited: nil, &block)
      return enum_for(:each_blog, last_update_from: last_update_from, is_edited: is_edited) unless block_given?

      page = 1
      loop do
        response = get_blogs(page: page, per_page: MAX_BULK_ITEMS, last_update_from: last_update_from, is_edited: is_edited)
        response.data.each(&block)
        break unless response.more_pages?

        page += 1
      end
    end

    private

    def validate_bulk_size!(items)
      raise ValidationError.empty_payload if items.empty?
      raise ValidationError.too_many_items(items.size, MAX_BULK_ITEMS) if items.size > MAX_BULK_ITEMS
    end

    def build_query_params(page, per_page, last_update_from, is_edited)
      params = {}
      params[:page] = page if page
      params[:per_page] = [per_page, MAX_BULK_ITEMS].min if per_page
      params[:last_update_time_from] = last_update_from.strftime("%Y-%m-%d %H:%M:%S") if last_update_from
      params[:is_edited] = is_edited.to_s if is_edited != nil

      return "" if params.empty?

      "?" + URI.encode_www_form(params)
    end

    def request(method, endpoint, data = nil)
      response = connection.send(method) do |req|
        req.url endpoint
        if data
          req.headers["Content-Type"] = "application/json"
          req.body = JSON.generate(data)
        end
      end

      handle_response(response)
    end

    def connection
      @connection ||= Faraday.new(url: @base_url) do |f|
        f.request :url_encoded
        f.adapter Faraday.default_adapter
        f.options.timeout = @timeout
        f.options.open_timeout = 10
        f.headers["Authorization"] = "Bearer #{@api_token}"
        f.headers["Accept"] = "application/json"
      end
    end

    def handle_response(response)
      body = response.body.empty? ? {} : JSON.parse(response.body)

      case response.status
      when 200..299
        body
      when 401
        raise ApiError.unauthorized
      else
        raise ApiError.from_response(response.status, body)
      end
    rescue JSON::ParserError
      raise ApiError.new("Invalid JSON response", http_code: response.status, response_body: response.body)
    end
  end
end
