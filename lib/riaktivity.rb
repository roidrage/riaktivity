require "riak"

module Riaktivity
  @options = {
    http_port: 8098,
    pb_port: 8087,
    host: '127.0.0.1',
    bucket: 'feeds'
  }

  def self.options=(options)
    @options.merge!(options)
  end

  def self.options
    @options
  end

  class Timeline
    def initialize(user, *timelines)
      @user = user
      @timelines = *timelines
      @options = Riaktivity.options
      @riak = Riak::Client.new(@options.slice(*Riak::Client::VALID_OPTIONS))
    end

    def converge()
      sort(merge())
    end
      
    def merge()
      activities = []
      @timelines.each do |timeline|
        timeline.each do |activity|
          if not activity_exists?(activity, in: activities)
            activities << activity
          end
        end
      end
      activities
    end

    def activity_exists?(activity, options = {})
      options[:in] ||= []
      options[:in].find {|a| a['id'] == activity['id']}
    end
    
    def sort(timeline)
      timeline.sort do |activity1, activity2|
        activity1['timestamp'] <=> activity2['timestamp']
      end
    end

    def add(activity)
      feed = bucket.get_or_new(@user)
      feed.data = [] if feed.data.nil?
      feed.data.unshift(activity)
      feed.store()
    end

    def bucket
      @riak.bucket(Riaktivity.options[:bucket])
    end
  end

  def add_activity(user, activity)
    Timeline.new(user).add(activity)
  end

  def get_timeline(user)
    Timeline.new(user).get()
  end
end
