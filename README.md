## Riaktivity

Store timelines in Riak with Ruby. A work in progress.

Stores a list of items in Riak, converges conflicting updates on both read
and write, keeping the list at a configurable length. Inspired by
Yammer's
[Streamie](http://blog.basho.com/2011/03/28/Riak-and-Scala-at-Yammer/) and
Disqus' [timak](https://github.com/bretthoerner/timak).

## Assumptions

* Unique IDs are generated elsewhere. They only need to be unique per entry, not per user feed
* Each entry includes a timestamp, based on which data is sorted
* Feeds are capped on size to prevent exponential growth
* Data on who follows who is maintained elsewhere

## Usage

``` ruby
class User
  include Riaktivity

  def add_entry(activity)
    add_activity(user_id, activity)
  end

  def get_feed()
    get_timeline(user_id)
  end
end

user = User.new(user_id: "roidrage")
user.add_entry(id: UUID.new, timestamp: Time.now, category: 'troll-face', properties: {entry_id: 2134})
```

## Configuration

``` ruby
Riaktivity.options = {host: '192.168.2.1',
                      protocol: 'pbc',
                      capped_at: 100,
                      bucket: 'troll-feed'}
```
