module CourierBot
  class Bot
    def initialize
      @slack_client = Slack::Web::Client.new
      @tasks = []
    end

    def identify!
      @bot_id = @slack_client.auth_test['user_id']
    end

    def dispatch(event)
      event_text = self.class.event_blocks_to_text_string(event)

      @tasks.each do |(pattern, task_class)|
        params =pattern.params(event_text)

        if params
          task_class.perform_async params, event_text, event
        else
          # TODO JSON logger
          warn "Pattern mismatch; event_text=#{event_text.inspect} pattern=#{pattern.inspect}"
        end
      end
    end

    def add_task(pattern, *args, &block)
      pattern = pattern.gsub('@me', "#{@bot_id}")
      pattern = Mustermann.new(pattern, *args)

      slack_client = @slack_client

      task_class = Class.new do
        include SuckerPunch::Job
      end

      task_context_class = Class.new(Contexts::Task).tap do |klass|
        klass.define_method(:slack_client) { slack_client }

        pattern.names.each do |name|
          klass.define_method(name.to_sym) { @params[name] }
        end
      end

      task_class.define_method :perform do |params, event_text, event_payload|
        task_ctx = task_context_class.new(params, event_text, event_payload)
        task_ctx.evaluate(&block)
      end

      @tasks << [pattern, task_class]
    end

    def add_periodic_task(wait_time, **kwargs, &block)
      ctx = Contexts::Timer.new(@slack_client, **kwargs)

      Concurrent::TimerTask
        .new(execution_interval: wait_time.to_i) { ctx.evaluate(&block) }
        .execute
    end

    def self.event_blocks_to_text_string(event)
      elements = event[:blocks]
        .flat_map { |block| block[:elements] }
        .flat_map { |rt| rt[:elements] }

      text = elements.map do |node|
        case node[:type]
        when 'text'
          # Replace no-break-space with a regular space (0xA0 for 0x20)
          node[:text].gsub(160.chr('UTF-8'), ' ')
        when 'user'
          node[:user_id]
        else nil
        end
      end

      text.compact!
      text.join
    end
  end
end
