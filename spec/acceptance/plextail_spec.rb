require 'spec_helper'
require 'fileutils'
require 'tmpdir'
require 'timeout'
require 'fakeweb_matcher'

describe 'Plextail' do
  let(:directory) { Dir.mktmpdir }

  before :each do
    FakeWeb.allow_net_connect = false

    FakeWeb.register_uri :post, %r{east\.logplex\.io/logs}, :body => 'OK'

    File.open(File.join(directory, 'data.log'), 'w')  { |f| f.puts 'stuff' }
    File.open(File.join(directory, 'error.log'), 'w') { |f| f.puts 'nonsense' }
  end

  after :each do
    FileUtils.rm_rf directory
  end

  def track(&block)
    begin
      Timeout.timeout(0.1) do
        Plextail.track(directory, "*.log", &block)
      end
    rescue Timeout::Error
      #
    end
  end

  it "passes each line through to Logplex" do
    track do |line|
      line.token      = 'token'
      line.process_id = 'spec'
    end

    FakeWeb.should have_requested(:post, %r{east\.logplex\.io/logs})
  end

  it "prompts with the correct file and line details" do
    yielded_file, yielded_line = nil, nil

    track do |line|
      yielded_file, yielded_line = line.file, line.raw

      line.token      = 'token'
      line.process_id = 'spec'
    end

    yielded_file.should == File.join(directory, 'error.log')
    yielded_line.should == 'nonsense'
  end

  it "handles single files matching the glob" do
    FileUtils.rm File.join(directory, 'error.log')
    yielded_file, yielded_line = nil, nil

    track do |line|
      yielded_file, yielded_line = line.file, line.raw

      line.token      = 'token'
      line.process_id = 'spec'
    end

    yielded_file.should == File.join(directory, 'data.log')
    yielded_line.should == 'stuff'
  end
end
