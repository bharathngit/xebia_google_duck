require 'logger'
require_relative '../../automation_core/properties'
require_relative '../../automation_core/logger'

require_relative '../../automation_core/selenium_actions'
require_relative '../page_locator_modules/bnadukat_google_duck_locators'

include GoogleDuckLocators

class GoogleDuckHelper < ActionWrapper

    def search_for(name = "Hello")
        $logger.info(__method__) {"'#{name}'' started."}
        wait_for_element( SEARCH_BOX,"SEARCH_BOX")
        is_element_displayed?(SEARCH_BOX, "SEARCH_BOX")
        type(SEARCH_BOX, name, "SEARCH_BOX")
        pressEnter
        wait_until_displayed(COMPLEMENTARY_RESULT_TITLE, "COMPLEMENTARY_RESULT_TITLE")
        title = get_text(COMPLEMENTARY_RESULT_TITLE,"COMPLEMENTARY_RESULT_TITLE")
        $logger.info(__method__) {"ends."}
        title
    rescue StandardError => e
        $logger.error(__method__) {": failed."}
        $logger.error(__method__) {"#{ExceptionFormatter.pretty_exception(e)}"}
        screenshot('GoogleDuckHelper','search_for')
        ""
    end

  
    def verify_results_link_with_text(link_text = "Hello")
        $logger.info(__method__) {" '#{link_text}' started."}
        results_locator = get_dynamic_locator(WEBRESULTS_LINK.clone, link_text)
        is_element_displayed?(results_locator, "WEBRESULTS_LINK '#{link_text}'")
        is_element_displayed? WIKIPEDIA_LINK, "WIKIPEDIA_LINK"
        $logger.info(__method__) {"ends."}
        true
    rescue StandardError => e
        $logger.error(__method__) {": failed."}
        $logger.error(__method__) {"#{ExceptionFormatter.pretty_exception(e)}"}
        screenshot('GoogleDuckHelper','verify_results_link_with_text')
        false
    end

    def count_wiki_links
        $logger.info(__method__) {" started."}
        get_elements(WIKI_LINK, "WIKI_LINK").count
        rescue StandardError => e
        $logger.error(__method__) {": failed."}
        $logger.error(__method__) {"#{ExceptionFormatter.pretty_exception(e)}"}
        screenshot('GoogleDuckHelper','count_wiki_links')
        0
    end

end
