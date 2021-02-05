# frozen_string_literal: true
require_relative '../lib/automation_core/logger'
require_relative '../lib/automation_core/properties.rb'
require_relative '../lib/bnadukat_google_duck/page_helper_components/bnadukat_google_duck_helper'


RSpec.describe BnadukatGoogleDuck do
	  # Hooks
  before(:all) do
    # Create the new GoogleDuckHelper object.  The initialize method creates
    # the BrowserDriver instance.  Open the browser
    # and navigate to the Pivot login page.
    @google_duck = GoogleDuckHelper.new
    @google_duck.open_browser
    @google_duck.get_url(Properties::LOGIN_URL)
  end

  after(:all) do
    # Disconnect from the browser and end session
    @google_duck.teardown
  end

  ############################Tests############################################################

  it "searches for 'ducks' on Google.com and then verify the results title", :skip => false do
    expect(@google_duck.search_for("ducks")).to eq "Duck"
  end
  
  it "searches for 'ducks' on Google.com and then verify the results contains 'Duck - Wikipedia' link", :skip => false do
  	expect(@google_duck.verify_results_link_with_text("Duck - Wikipedia")).to be true
  end

  it "searches for 'ducks' on Google.com and then verify the results contains 'Domestic duck - Wikipedia' link", :skip => false do
  	expect(@google_duck.verify_results_link_with_text("Domestic duck - Wikipedia")).to be false
  end

  it "searches for 'ducks' on Google.com and then verify the results contains Wikepedia links", :skip => false do
  	expect(@google_duck.count_wiki_links).to satisfy { |value| value >= 6}
  end
  
end
