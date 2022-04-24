module CourierBot
  module Contexts
    class Bot
      def initialize(bot, script_file)
        @bot = bot
        @script_file = script_file
      end

      def evaluate
        instance_eval File.read(@script_file), @script_file, 1
      end

      private

      def task(*args, **kwargs, &block)
        @bot.add_task(*args, **kwargs, &block)
      end

      def every(*args, **kwargs, &block)
        @bot.add_periodic_task *args, **kwargs, &block
      end
    end
  end
end
