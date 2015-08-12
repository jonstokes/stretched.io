module Chronograph
  def self.included(base)
    base.class_eval do
      extend ClassMethods
    end
  end

  def benchmark(field, &block)
    bench_var = context.send("#{self.class.bench_var_name}=", {})
    bench_var[field] ||= 0
    start = Time.now
    retval = yield
    bench_var[field] = ((Time.now - start) * 1000)
    retval
  end

  module ClassMethods
    def benchmark_with(attr)
      @bench_var_name = attr
    end

    def bench_var_name
      @bench_var_name
    end
  end
end
