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

      def task(*args, &block)
        @bot.add_task(*args, &block)
      end
    end
  end
end
