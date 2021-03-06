require 'set'

module Medianoche
  class Collection
    attr_reader :posts
    attr_reader :tags
    def initialize
      @posts = Posts.new self
      @tags = Tags.new self
    end

    private
    class Posts
      def initialize(parent)
        @parent = parent
        @coll = Hash.new
      end

      def add(post)
        @coll[post.uuid] = post
        post.tags.each do |t|
          @parent.tags.link t.tagname, post
        end
      end

      def get(uuid)
        @coll[uuid]
      end

      def list
        @coll.values
      end
    end

    class Tags
      def initialize(parent)
        @parent = parent
        @coll = Hash.new
      end

      def link(tagname, post)
        @coll[tagname] ||= Set.new
        @coll[tagname].add post
      end

      def list
        @coll.keys.reject do |k|
          k =~ /^password=/
        end
      end

      def get(tagname)
        @coll[tagname] || []
      end

      def related(tagname)
        posts = @coll[tagname] || Set.new
        posts.map do |p|
          p.tags.map(&:tagname)
        end.flatten.uniq
      end
    end
  end
end
