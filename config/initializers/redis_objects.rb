class Redis
  class SortedSet
    def pop
      return unless redis.zcard(key) > 0
      redis.watch key
      element = redis.zrange(key, 0, 0)
      redis.multi
      redis.zrem(key, element)
      redis.exec
      element.first
    end
  end
end
