require 'logger'
require_relative '../automation_core/properties'
require_relative '../automation_core/logger'
require 'faraday'
require 'json'

module BnadukatFaraday

	def get_request(uri)
	    $logger.info(__method__) {" for '#{uri}' started."}
		data = Faraday.get(uri).body
		JSON.parse(data, symbolize_names: true)
	end

end