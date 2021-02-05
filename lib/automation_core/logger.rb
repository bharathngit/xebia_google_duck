require 'logger'

# This class helps print logs to multiple outlets (STDOUT and logfile), so that we can keep track of things during execution
class MultiIO
  def initialize(*targets)
     @targets = targets
  end

  def write(*args)
    @targets.each {|t| t.write(*args)}
  end

  def close
    @targets.each(&:close)
  end
end

# Get the Relative path of the log file.
file_path = File.join(File.absolute_path('../..', File.dirname(__FILE__)), '/logs', "debug.log")
# Open the log file
log_file = File.open( file_path , "a")
$logger = Logger.new( MultiIO.new( STDOUT, log_file ), 'weekly' )
# Set up logging; Levels: [Debug, Info, Warn, Error, Fatal, Unknown]
$logger.level = Logger::DEBUG
# Setup format type
$logger.formatter = proc do |severity, datetime, progname, msg|
  "[#{datetime}] #{severity}: #{progname} #{msg}\n"
end
