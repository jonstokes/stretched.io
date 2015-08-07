module Chronograph
  def self.included(base)
    base.class_eval do
      provides(:measurements) { {} }
    end
  end

  def measure(field, &block)
    measurements[field] ||= 0
    start = Time.now
    retval = yield
    measurements[field] += ((Time.now - start) * 1000)
    retval
  end
end
