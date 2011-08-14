module Riaktivity
  class Timeline
    def initialize(*timelines)
      @timelines = *timelines
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
  end
end
