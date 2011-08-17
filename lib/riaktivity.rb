require "riak"

module Riaktivity
  @options = {
    http_port: 8098,
    pb_port: 8087,
    host: '127.0.0.1',
    bucket: 'feeds',
    trim_at: 1000
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

    def converge(*timelines)
      sort(merge(*timelines))
    end
      
    def merge(*timelines)
      activities = []
      timelines.each do |timeline|
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

    def trim(timeline)
      timeline.slice(0, @options[:trim_at])
    end

    def add(activity)
      activity.stringify_keys!
      feed = bucket.get_or_new(@user)
      maybe_converge_siblings(feed)
      feed.data = [] if feed.data.nil?
      feed.data.unshift(activity)
      feed.data = trim(feed.data)
      feed.store()
    end

    def maybe_converge_siblings(feed)
      if feed.conflict?
        timelines = feed.siblings.map(&:data)
        feed.data = converge(*timelines)
        feed.content_type = "application/json"
      end
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
