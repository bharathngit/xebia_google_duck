require 'selenium-webdriver'

require_relative './properties'
require_relative './logger'
require_relative './exception_formatter'

class BrowserDriver
  DRIVER_FOLDER = '/drivers'.freeze

  # Creates getter methods for instance variables
  attr_reader :web_driver
  attr_reader :screenshot_folder
  attr_reader :browser

  # Opens the web browser
  def open_browser
    @browser = Properties::BROWSER
    setup
    rescue StandardError => e
    $logger.error ExceptionFormatter.pretty_exception(e)
    throw e
  end

  # Tears down the session and closes the web browser
  def teardown
    $logger.info(__method__) { 'Closing the session and the browser.' }
    @web_driver.quit
  end


  private

  def make_path_to(driver_executable)
    File.join(File.absolute_path('../..', File.dirname(__FILE__)), DRIVER_FOLDER, driver_executable)
  end

  def chrome_driver_path
    make_path_to('chromedriver')
  end

  def firefox_driver_path
    make_path_to('geckodriver.exe')
  end


  def create_screenshot_folder
    @screenshot = File.join(File.absolute_path('../..', File.dirname(__FILE__)), '/screenshots')
    Dir.mkdir(@screenshot) unless File.exist?(@screenshot)
    directory_name     = Time.now.strftime('%Y-%m-%d_%H_%M_%S')
    @screenshot_folder = File.join(File.absolute_path('../..', File.dirname(__FILE__)), '/screenshots', directory_name)
    Dir.mkdir(@screenshot_folder) unless File.exist?(@screenshot_folder)
  end

  # Create the browser instance, opens & maximizes the browser
  def setup
    create_screenshot_folder

    $logger.info(__method__) { "Opening browser: #{@browser.upcase}" }
    @web_driver = case @browser.upcase
                    when 'CHROME'
                      Selenium::WebDriver::Chrome::Service.driver_path = chrome_driver_path
                      Selenium::WebDriver.for :chrome

                    when 'FIREFOX'
                      Selenium::WebDriver::Firefox::Service.driver_path = firefox_driver_path
                      Selenium::WebDriver.for :firefox

                    else
                      raise ArgumentError, "Unsupported browser type: #{@browser}"
                  end

    @web_driver.manage.window.maximize
  rescue StandardError=> e
    $logger.error ExceptionFormatter.pretty_exception(e)
    throw e
  end

end

# bd = BrowserDriver.new
# bd.open_browser
# bd.web_driver.get(Properties::LOGIN_URL)
# bd.teardown
