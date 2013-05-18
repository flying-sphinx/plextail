class Plextail::Line
  DEFAULTS = {
    :version    => '<134>1',
    :hostname   => `hostname`.strip,
    :message_id => '- -'
  }

  attr_accessor :file, :raw, :token, :version, :timestamp, :hostname,
    :process_id, :message_id, :message

  def initialize(file, raw)
    @file, @raw = file, raw
    @version    = DEFAULTS[:version]
    @timestamp  = current_timestamp
    @hostname   = DEFAULTS[:hostname]
    @message_id = DEFAULTS[:message_id]
    @message    = raw.dup
  end

  def to_s
    unless valid?
      raise Plextail::InvalidLineError, "Missing #{missing_parts.join(', ')}"
    end

    string = parts.join(' ')

    "#{string.bytes.to_a.length} #{string}"
  end

  def valid?
    parts.all? { |part| part && part.length > 0 }
  end

  private

  def current_timestamp
    time     = Time.now
    fraction = (".%06i" % time.usec)[0, 7]
    "#{time.strftime("%Y-%m-%dT%H:%M:%S")}#{fraction}+00:00"
  end

  def missing_parts
    [
      :version, :timestamp, :hostname, :token, :process_id, :message_id,
      :message
    ].select { |part| send(part).nil? || send(part).length == 0 }
  end

  def parts
    [version, timestamp, hostname, token, process_id, message_id, message]
  end
end
