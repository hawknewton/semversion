# frozen_string_literal: true

require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem
loader.setup

module Semversion
  class Error < StandardError; end
end

loader.eager_load # optionally
