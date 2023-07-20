module TestUp
  module SketchUpTests
    module FeatureSwitchHelper

      ENABLED_FEATURE_SWITCHES_PATTERN = /Features Enabled for this Launch:\s*=+\s*(.+)/m

      # @return [Array<String>]
      def enabled_features
        features = Sketchup.feature_switch.match(ENABLED_FEATURE_SWITCHES_PATTERN)
        features.captures[0].strip.split("\n")
      end

      # @param [String] feature
      def feature_switch?(feature)
        enabled_features.include?(feature)
      end

    end
  end
end
