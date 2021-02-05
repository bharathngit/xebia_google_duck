# frozen_string_literal: true
require_relative '../lib/automation_core/logger'
require_relative '../lib/automation_core/properties.rb'
require_relative '../lib/bnadukat_faraday_api/bnadukat_faraday_api_helper'
include BnadukatFaraday

RSpec.describe BnadukatGoogleDuck do

  it "GET requests using Faraday", :skip => false do
    expect(get_request(Properties::URI)).to be_kind_of(Array)
    expect(get_request(Properties::URI)[0]).to be_kind_of(Hash)
    expect(get_request(Properties::URI)[0]).to have_key(:userId)
    expect(get_request(Properties::URI)[0]).to have_key(:id)
    expect(get_request(Properties::URI)[0]).to have_key(:title)
    expect(get_request(Properties::URI)[0]).to have_key(:body)
  end
  
end
