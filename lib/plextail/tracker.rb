# encoding: utf-8
require 'pty'
require 'faraday'

class Plextail::Tracker
  URL = ENV['LOGPLEX_URI'] || 'https://east.logplex.io'

  def initialize(*glob)
    @glob = File.join *glob
  end

  def pipe(&block)
    if @glob.empty?
      pipe_from_input nil, &block
    else
      pipe_from_glob Dir[glob].first, &block
    end
  end

  private

  attr_reader :glob

  def connection
    @connection ||= Faraday.new(:url => URL) do |connection|
      connection.use Faraday::Adapter::NetHttp
    end
  end

  def pipe_from_glob(file, &block)
    PTY.spawn("tail -f #{glob}") do |stdin, stdout, pid|
      stdin.each do |string|
        file = process_line file, string, &block
      end
    end
  rescue PTY::ChildExited
    puts "The child process exited!"
  end

  def pipe_from_input(file, &block)
    ARGF.each_line do |string|
      file = process_line file, string, &block
    end
  end

  def process_line(file, string, &block)
    string.strip!
    return $1 if string[/^==> (.+) <==$/]

    to_plex Plextail::Line.new file, string, &block if string.length > 0

    file
  end

  def to_plex(line)
    connection.basic_auth 'token', line.token
    connection.post('/logs', line.to_s) do |request|
      request.headers['Content-Type']   = 'application/logplex-1'
      request.headers['Content-Length'] = line.to_s.bytes.to_a.length.to_s
    end
  end
end
