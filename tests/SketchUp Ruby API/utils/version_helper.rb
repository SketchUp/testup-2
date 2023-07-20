module TestUp
    module SketchUpTests
      module VersionHelper

        # @param [Integer] major Minimum major version
        # @param [Integer] minor Minimum minor version
        # @param [Integer] patch Minimum patch version
        def sketchup_older_than(major, minor = 0, patch = 0)
          su_major, su_minor, su_path = Sketchup.version.split('.').map(&:to_i)
          return true if su_major < major
          return true if su_minor < minor
          # Our development build always have the build number set to 0.
          # So any patch release requirements to skip a test cannot be checked
          # in a local development build. We assume a patch version of 0 means
          # a development build and therefor skip the patch version check.
          if patch > 0
            return true if su_major < major
          end
          false
        end

        # @param [Integer] major Minimum major version
        # @param [Integer] minor Minimum minor version
        # @param [Integer] patch Minimum patch version
        def sketchup_older_than_or_equal(major, minor = 0, patch = 0)
          sketchup_older_than(major, minor, patch) ||
              [major, minor, patch] == Sketchup.version.split('.').map(&:to_i)
        end
  
      end
    end
  end
  