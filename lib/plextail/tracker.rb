require 'pty'
require 'faraday'

class Plextail::Tracker
  URL = ENV['LOGPLEX_URI'] || 'https://east.logplex.io'

  def initialize(*glob)
    @glob = File.join *glob
  end

  def pipe(&block)
    file = Dir[glob].first
    PTY.spawn("tail -f #{glob}") do |stdin, stdout, pid|
      stdin.each do |string|
        string.strip!
        if string[/^==> (.+) <==$/]
          file = $1
        elsif string.length > 0
          line = Plextail::Line.new file, string
          block.call line
          to_plex line
        end
      end
    end
  rescue PTY::ChildExited
    puts "The child process exited!"
  end

  private

  attr_reader :glob

  def connection
    @connection ||= Faraday.new(:url => URL) do |connection|
      connection.use Faraday::Adapter::NetHttp
    end
  end

  def to_plex(line)
    connection.basic_auth 'token', line.token
    connection.post('/logs', line.to_s) do |request|
      request.headers['Content-Type']   = 'application/logplex-1'
      request.headers['Content-Length'] = line.to_s.bytes.to_a.length.to_s
    end
  end
end
