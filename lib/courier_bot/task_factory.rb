module CourierBot
  module TaskFactory
    def self.create()
      task_class = Class.new { include SuckerPunch::Job }

      task_context_class
    end
  end
end
