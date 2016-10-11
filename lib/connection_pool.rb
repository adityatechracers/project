module ConnectionPool 
  def with_connection(method)
    old = instance_method(method)
    define_method method do |*args|
      ActiveRecord::Base.connection_pool.with_connection do
        old.bind(self).call(*args)
      end
    end
  end 
end   