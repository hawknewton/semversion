# frozen_string_literal: true

require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem
loader.setup

module Semversion
  class Error < StandardError; end

  class Logger
    class << self
      attr_writer :logger

      def info(str)
        return unless @logger

        @logger.puts(str)
      end
    end
  end

  Logger.logger = $stdout
end

loader.eager_load # optionally
