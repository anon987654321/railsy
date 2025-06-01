module Brgen
  class Facebook
    cattr_accessor :app_namespace

    def self.post(user_id, object_id, object_type, action, object_url)
      user = User.find(user_id)
      object = object_type.constantize.find(object_id)
      fb_object = user.facebook.put_connections("me", "#{app_namespace}:#{action}", post: object_url)
      object.update_attributes({ facebook_id: fb_object["id"] })
    end

    def self.delete(user_id, object_id)
      user = User.find(user_id)
      user.facebook.delete_object(object_id)
    end
  end
end

