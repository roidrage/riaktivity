require File.expand_path(File.dirname(__FILE__) + "/spec_helper")
require "riak/test_server"

describe Riaktivity do
  include Riaktivity

  describe Riaktivity::Timeline do
    let(:timeline1) do
      [{
        id: 1,
        timestamp: Time.now.utc.to_i,
        category: 'likes-message',
        properties: {
          liker_id: 123,
          like_id: 321
        }
      }.stringify_keys,{
        id: 2,
        timestamp: Time.now.utc.to_i,
        category: 'likes-message',
        properties: {
          liker_id: 124,
          like_id: 323
        }
      }.stringify_keys]
    end

    let(:timeline2) do
      [{
        id: 1,
        timestamp: Time.now.utc.to_i,
        category: 'likes-message',
        properties: {
          liker_id: 123,
          like_id: 321
        }
      }.stringify_keys,{
        id: 3,
        timestamp: Time.now.utc.to_i - 3,
        category: 'likes-message',
        properties: {
          liker_id: 123,
          like_id: 321
        }
      }.stringify_keys]
    end

    let(:timeline) do
      Riaktivity::Timeline.new("roidrage", timeline1, timeline2)
    end

    describe "converging timelines" do
      it "merges two timelines into one" do
        result = timeline.converge()
        result.size.should == 3
      end

      it "doesn't store ID duplicates" do
        result = timeline.converge()
        result.select {|activity| activity['id'] == 1}.size.should == 1
      end

      it "orders the results by timestamp" do
        result = timeline.converge()
        result.first['id'].should == 3
      end
    end

    describe "adding an activity" do
      include Riaktivity
      Riaktivity.options = {http_port: 9000}
      let(:user) {"roidrage"}
      let(:activity) {
        {
          id: 3,
          timestamp: Time.now.utc.to_i - 3,
          category: 'likes-message',
          properties: {
            liker_id: 123,
            like_id: 321
          }
        }.stringify_keys
      }
      let(:riak) {Riak::Client.new(Riaktivity.options.slice(*Riak::Client::VALID_OPTIONS))}
      let(:test_server) {
        Riak::TestServer.new(bin_dir: "/Volumes/Users/pom/.riak/install/riak-0.14.2/bin", temp_dir: "/tmp/riak/test-server")
      }

      before(:all) {
        test_server.cleanup
        test_server.prepare!
        test_server.start
        riak.bucket(Riaktivity.options[:bucket]).props = {allow_mult: true}
      }

      before(:each) {
        test_server.recycle
      }

      it "adds and activity to the list" do
        add_activity("david", id: 1235, timestamp: Time.now.utc.to_i, category: 'likes-message', properties: {}) 
        riak.bucket(Riaktivity.options[:bucket]).get("david")
      end
    end
  end
end
