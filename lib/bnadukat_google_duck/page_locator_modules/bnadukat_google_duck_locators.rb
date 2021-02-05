
module GoogleDuckLocators

  SEARCH_BOX = { css: 'input[name="q"]'}
  COMPLEMENTARY_RESULT_TITLE = { xpath: '//div[@id="wp-tabs-container"]//*[@data-attrid="title"]/span' }
  WEBRESULTS_LINK = { xpath: "//h1[contains(text(),'Search Results')]/following-sibling::div//h3/span[text()='<REPLACE>']"}
  WIKIPEDIA_LINK =  { xpath: "//h3[text()='Description']/following-sibling::span/a[ text() = 'Wikipedia' ]"}
  WIKI_LINK = {xpath: "//a[text()='Wikipedia']"}
end


