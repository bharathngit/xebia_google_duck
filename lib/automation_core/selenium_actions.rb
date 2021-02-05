require 'forwardable'

require_relative './properties'
require_relative './browser_driver'
require_relative './logger'

##########################################################################
#
#   ActionWrapper class wraps the common Selenium actions
#
# => This class contains all the wrapper methods of Selenium that
#    are re-used by the test components
# => This class extends Forwardable in order to delegate three methods to BrowserDriver.
# => This class receives a driver on instantiation or creates a new driver (instance of BrowserDriver)
#
##########################################################################
class ActionWrapper

  # The Forwardable supports delegation of methods to another class.
  extend Forwardable

  # Class constructor.
  #
  # @param [BrowserDriver, nil] browser_manager The browser manager to use. If not given, one will be created.
  def initialize(browser_manager = BrowserDriver.new)
    @browser_manager = browser_manager
  end

  attr_reader :browser_manager

  # ActionWrapper delegates the methods open_browser, teardown and driver to the BrowserDriver class. (This replaces
  # one layer of inheritance and relies on composition of objects instead.)
  # These BrowserDriver methods can be invoked on an instance of ActionWrapper or an instance of a descendant class
  # of ActionWrapper.  When ActionWrapper receives the request, it delegates the request to the BrowserDriver method of
  # the same name.

  def_delegators :@browser_manager, :open_browser
  def_delegators :@browser_manager, :teardown
  def_delegators :@browser_manager, :web_driver
  def_delegators :@browser_manager, :screenshot_folder

  WAIT = 60

  def get_url(url)
    open_url(url)
  end

  #
  # INTERNAL
  #

  protected

  ###### Selenium actions ##########################################

  # Click on an element.
  #
  # @param [String] locator Element locator.
  # @param [String] name Name to reference in logger output.
  # @param [Boolean] raise_exception If true, will raise an exception if the click fails.
  #
  # @return [Boolean] true if the element was clicked, false if the click failed.
  #
  # @raise [Exception] - if raise_exception is true and the element click failed.
  def click(locator, name, raise_exception = true)
    $logger.info(__method__) { "on '#{name}'." }
    $logger.debug(__method__) { locator }
    highlight( web_driver.find_element(locator), 0, "yellow", "red", "2.5px", "dashed" )
    web_driver.find_element(locator).click
    $logger.info(__method__) { "success." }
    true
  rescue StandardError => e
    $logger.error(__method__) { "failed." }
    raise e if raise_exception
    $logger.error ExceptionFormatter.pretty_exception(e)
    false
  end

  # Get an element.
  #
  # @param [String] locator Element locator.
  # @param [String] name Name to reference in logger output.
  # @param [Boolean] raise_exception If true, will raise an exception if the element is not found.
  # @param [Boolean] log_error If true, will log an error if the element is not found.
  #
  # @return [Selenium::WebDriver::Element] the element.
  #
  # @raise [Exception] - if raise_exception is true and the element could not be found.

  def get_element(locator, name, raise_exception = true, log_error = true)
    $logger.info(__method__) { "#{name}" }
    web_driver.find_element(locator)
    rescue StandardError => e
    $logger.error(__method__) { "failed." }
    raise e if raise_exception
    $logger.error ExceptionFormatter.pretty_exception(e) if log_error
    return nil
  end

  def get_elements(locator, name, raise_exception = true, log_error = true)
    $logger.info(__method__) { "#{name}" }
    web_driver.find_elements(locator)
    rescue StandardError => e
    $logger.error(__method__) { "failed." }
    raise e if raise_exception
    $logger.error ExceptionFormatter.pretty_exception(e) if log_error
    nil
  end


  # Is an element displayed on the page?
  #
  # @param [String] locator Element locator.
  # @param [String] name Name to reference in logger output.
  # @param [Boolean] raise_exception If true, will raise an exception if the element is not displayed.
  # @param [Boolean] log_error If true and raise_exception is false, will log an error if the element is not displayed.
  #
  # @return [Boolean] true if the element is displayed, false if it is not.
  #
  # @raise [Exception] - if raise_exception is true and the element is not displayed.
  def is_element_displayed?(locator, name, raise_exception = true, log_error = true)
    $logger.info(__method__) { "Verifying element #{name}" }
    $logger.debug(__method__) { locator }

    if( get_element(locator, name).displayed?)
      highlight(web_driver.find_element(locator), 0, "blue", "red", "2px", "dashed" )
      $logger.info(__method__) { "true" }
      highlight(web_driver.find_element(locator), 0, "green", "red", "2px", "solid" )
     true
    else
      $logger.info(__method__) { "Element is no longer displayed." }
      raise StandardError.new("Element #{name} is not displayed.") if raise_exception
    end
  rescue StandardError => e
    $logger.info(__method__) { "false" }
    raise e if raise_exception
    $logger.error ExceptionFormatter.pretty_exception(e) if log_error
    false
  end

  # Scroll up/down a page to an element and brings it into the view.
  #
  # @param [String] locator Element locator.
  # @param [String] name Name to reference in logger output.
  # @param [Boolean] raise_exception If true, will raise an exception if the scroll fails.
  #
  # @return [Boolean] true if the element was scrolled, false if the scroll failed.
  #
  # @raise [Exception] - if raise_exception is true and the element scroll failed.
  def js_scroll_into_view(locator, name, raise_exception = true)
    $logger.info(__method__) { "Scrolling to #{name}" }
    $logger.debug(__method__) { locator }
    highlight( web_driver.find_element(locator), 0, "yellow", "blue", "2.5px", "dashed" )
    js_script = 'arguments[0].scrollIntoView(true);'
    element   = web_driver.find_element(locator)
    web_driver.execute_script(js_script, element)
    delay_for(1)
    highlight( web_driver.find_element(locator), 0, "green", "blue", "2.5px", "solid" )
    $logger.info(__method__) { "success." }
    true
  rescue StandardError => e
    $logger.error(__method__) { "failed." }
    raise e if raise_exception
    $logger.error ExceptionFormatter.pretty_exception(e)
    false
  end



  # Mouse-over on an element.
  #
  # @param [String] locator Element locator.
  # @param [String] name Name to reference in logger output.
  # @param [Boolean] raise_exception If true, will raise an exception if the hover fails.
  #
  # @return [Boolean] true if the element is hovered over, false if hover failed.
  #
  # @raise [Exception] - if raise_exception is true and the hover failed.
  def scroll_to_element(locator, name, raise_exception = true)
    $logger.info(__method__) { "#{name}" }
    $logger.debug(__method__) { locator }
    highlight( web_driver.find_element(locator), 0, "yellow", "blue", "2.5px", "dashed" )
    element = get_element(locator, name)
    web_driver.action.move_to(element).perform
    highlight( web_driver.find_element(locator), 0, "green", "blue", "2.5px", "solid" )
    true
  rescue StandardError => e
    $logger.error(__method__) { "failed." }
    $logger.error ExceptionFormatter.pretty_exception(e)
    raise e if raise_exception
    false
  end

  # Open a url in a browser.
  #
  # @param [String] url The URL.
  def open_url(url)
    case url
      when Properties::QA_URL
        $logger.info(__method__) { 'Testing on QA environment' }
      when Properties::STAGE_URL
        $logger.info(__method__) { 'Testing on STAGE environment' }
      when Properties::DEV_URL
        $logger.info(__method__) { 'Testing on DEV environment' }
      else
        raise ArgumentError, "Unsupported environment: #{url}"
    end

    $logger.info(__method__) { "Opening: #{url}" }
    web_driver.get url
  rescue Exception => e
    $logger.error(__method__){'failed'}
    $logger.error e.message
    screenshot(self.class.name, "#{__method__.to_s}")
    raise e.new("Network disconnected. Unable to open URL")
    $logger.error ExceptionFormatter.pretty_exception(e)
  end

  # Sends key presses to an element.
  #
  # @param [String] locator Element locator.
  # @param [String] name Name to reference in logger output.
  # @param [Boolean] raise_exception If true, will raise an exception if the key entry fails.
  #
  # @return [Boolean] true if the keys presses were sent, false if they failed.
  #
  # @raise [Exception] - if raise_exception is true and the key presses failed.
  def type(locator, text, name, raise_exception = true)
    $logger.info(__method__) { "'#{text}' to '#{name}'" }
    $logger.debug(__method__) { locator }
    highlight(web_driver.find_element(locator), 0, "yellow", "blue", "2.5px", "dashed")
    #Clear existing text before typing
    web_driver.find_element(locator).clear
    web_driver.find_element(locator).send_keys(text)
    highlight( web_driver.find_element(locator), 0, "green", "blue", "2.5px", "solid" )
    $logger.info(__method__) { "success." }
    true
    rescue StandardError => e
      $logger.error(__method__) { "failed." }
      $logger.error(__method__) { locator }
      $logger.error ExceptionFormatter.pretty_exception(e)
    raise e if raise_exception
    false
  end

  ###### Screenshots and Waits #####################################

  # Save screenshot of error condition
  # @param [String] class_name The name of the class where the error occurred
  # @param [String] method_name The name of the method where the error occurred
  def screenshot(class_name = '', method_name = '')
    $logger.info(__method__) { 'begins.'}
    web_driver.save_screenshot "#{screenshot_folder}/#{Time.now.strftime("#{class_name}_#{method_name}_%Y%m%d_%H%M%S")}.png"
     $logger.info "Screenshot saved in path: #{screenshot_folder}/#{Time.now.strftime("#{class_name}_#{method_name}_%Y%m%d_%H%M%S")}.png"
     $logger.info(__method__) { 'successful.'}
  rescue StandardError => e
    $logger.error(__method__) { 'failure!'}
    $logger.error(__method__) { "#{ExceptionFormatter.pretty_exception(e)}" }
    false
  end

  # Wait until an element is displayed in the page.
  #
  # @param [String] locator Element locator.
  # @param [String] name Name to reference in logger output.
  # @param [Integer] seconds How long to look for the element, in seconds.
  # @param [Boolean] raise_exception If true, will raise an exception if the element is not found.
  #
  # @return true if the element was found, false if not found.
  #
  # @raise [Selenium::WebDriver::Error::TimeOutError] - if raise_exception is true and the element could not be found.
  def wait_for_element(locator, name, seconds = WAIT, raise_exception = true)
    $logger.info(__method__) {": #{name}"}
    wait = Selenium::WebDriver::Wait.new(:timeout => seconds)
    wait.until { web_driver.find_element(locator) }
    highlight( web_driver.find_element(locator), 0, "yellow", "blue", "2px", "solid" )
    $logger.info(__method__) {"successful."}
    true
  end

  def wait_until_displayed(locator, name, seconds = WAIT, raise_exception = true )
    $logger.info(__method__) {": #{name}"}
    wait = Selenium::WebDriver::Wait.new(:timeout => seconds)
    wait.until { web_driver.find_element(locator).displayed? }
    highlight( web_driver.find_element(locator), 0, "yellow", "blue", "2px", "solid" )
    $logger.info(__method__) {"successful."}
    true
  end


  # Wait until an element disappears from the page.
  def wait_until_disappears(locator, name, seconds = WAIT, raise_exception = true)
    $logger.info(__method__) { ": '#{name}'" }

    wait = Selenium::WebDriver::Wait.new(:timeout => seconds)
    # wait.until { web_driver.find_element(locator).displayed? }
    wait.until { !is_element_displayed?(locator, name, false, false) } if is_element_displayed?(locator, name, false, false)
    $logger.info(__method__) { ": '#{name}' is success." }
    true
  end

  # Wait for 3 seconds.
  def short_delay
    delay_for 3
  end

  # Wait for 10 seconds.
  def long_delay
    delay_for 10
  end

  # Delay for N seconds.
  def delay_for(seconds)
    $logger.info "Sleeping for  #{seconds} secs"
    sleep seconds
  end

  # THis method highlights the webelements
  # @param [WebElement] element
  # @param [integer] time
  def highlight( element, time = 0, border_color = "yellow", font_color = "black", border_thickness = '2px', border_style = 'solid', raise_exception = false, ignore_js_error = true)
    orig_style = element.attribute("style")
    web_driver.execute_script("arguments[0].setAttribute(arguments[1], arguments[2])", element, "style", "border: #{border_thickness} #{border_style} #{border_color}; color: #{font_color}; font-weight: bold;")
      if time > 0
        web_driver.execute_script("arguments[0].setAttribute(arguments[1], arguments[2])", element, "style", orig_style)
      end
    rescue StandardError => e
      $logger.error(__method__) {" failed."}
      $logger.error(__method__) { e.message }
      raise e if raise_exception
      return true if ignore_js_error
      false
  end

# The below method returns title of the current window
  def get_window_title
    $logger.info(__method__) {" begin."}
    web_driver.title
  end

  # ActionBuilder - Press ENTER key.
  def pressEnter(raise_exception = true)
    $logger.info(__method__) { "." }
     web_driver.action.key_down(:enter).perform
     delay_for(1)
     web_driver.action.key_up(:enter).perform
    $logger.info(__method__) { "success." }
    true
  end

  def get_text(locator, name, raise_exception = true, log_error = true)
    $logger.info(__method__) { " of element #{name}" }
    $logger.debug(__method__) { locator }

    if( get_element(locator, name).displayed?)
      highlight(web_driver.find_element(locator), 0, "blue", "red", "2px", "dashed" )
      $logger.info(__method__) { "true" }
      highlight(web_driver.find_element(locator), 0, "green", "red", "2px", "solid" )
      el_text = get_element(locator, name).text
      $logger.info(__method__) {"Text is: '#{el_text}'"}
      el_text
    else
      $logger.info(__method__) { "Element is no longer displayed." }
      raise StandardError.new("Element #{name} is not displayed.") if raise_exception
    end

  end

  def get_dynamic_locator(locator, replace_text)
     $logger.info(__method__) { "with '#{replace_text}'" }
     $logger.info(__method__) { locator.to_s }

     l_clone = locator.clone
     new_locator = {}
     l_clone.each do |key,value|
        new_value = value.clone 
        new_value['<REPLACE>'] = replace_text
        new_locator[key] = new_value
     end
    new_locator
  end

end
