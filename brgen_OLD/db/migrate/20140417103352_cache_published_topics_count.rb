class CachePublishedTopicsCount < ActiveRecord::Migration
  def up
    execute "update forem_forums set published_topics_count=(select count(*) from forem_topics where forum_id=forem_forums.id AND (sponsored = 'f') AND (forem_topics.state = 'published'))"
  end

  def down
  end
end

