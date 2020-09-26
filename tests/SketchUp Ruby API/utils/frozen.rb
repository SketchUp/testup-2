module TestUp
  module SketchUpTests
    module Frozen

      FROZEN_ERROR = RUBY_VERSION.to_f < 2.5 ? RuntimeError : FrozenError

    end
  end
end
