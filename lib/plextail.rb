module Plextail
  class InvalidLineError < StandardError
  end

  def self.track(*glob, &block)
    Plextail::Tracker.new(*glob).pipe(&block)
  end
end

require 'plextail/line'
require 'plextail/tracker'
