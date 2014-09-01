# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require "testup/testcase"


# interface class Animation
# http://www.sketchup.com/intl/developer/docs/ourdoc/animation
class TC_Animation < TestUp::TestCase

  def setup
    # ...
  end

  def teardown
    # ...
  end


  class TestAnimation

    def initialize(frames_to_play = 1)
      @play_state = :not_started
      @frames_to_play = frames_to_play
      @frames = 0
    end

    def play_state
      @play_state
    end

    def nextFrame(view)
      @play_state = :playing
      new_eye = view.camera.eye
      new_eye.z = new_eye.z + 1.0
      view.camera.set(new_eye, view.camera.target, view.camera.up)
      view.show_frame

      # Play only five frames at a time.
      @frames = @frames + 1
      @frames < 5
    end

    def stop
      @play_state = :stopped
    end

  end # class TestAnimation


  # Intercept menu code to avoid tests from creating a flood of test menus.
  module UI
    def self.menu(title)
      TestUp::MenuGuard.menu(title)
    end
  end


  # ========================================================================== #
  # class Animation
  # http://www.sketchup.com/intl/developer/docs/ourdoc/animation

  def test_introduction_api_example_1
    # Methods cannot contain class definitions, so this code example must be
    # evaluated.
    eval <<-END_OF_EXAMPLE
    # This is an example of a simple animation that floats the camera up to
    # a z position of 200". The only required method for an animation is
    # nextFrame. It is called whenever you need to show the next frame of
    # the animation. If nextFrame returns false, the animation will stop.
    class FloatUpAnimation
      def nextFrame(view)
        new_eye = view.camera.eye
        new_eye.z = new_eye.z + 1.0
        view.camera.set(new_eye, view.camera.target, view.camera.up)
        view.show_frame
        return new_eye.z < 500.0
      end
    end

    # This adds an item to the Camera menu to activate our custom animation.
    UI.menu("Camera").add_item("Run Float Up Animation") {
      Sketchup.active_model.active_view.animation = FloatUpAnimation.new
    }
    END_OF_EXAMPLE
  end

  def test_introduction_api_example_2
    Sketchup.active_model.active_view.animation = nil
  end


  # ========================================================================== #
  # method Animation.nextFrame
  # http://www.sketchup.com/intl/developer/docs/ourdoc/animation#nextFrame

  def test_nextFrame_api_example
    def nextFrame(view)
      # Insert your handler code for updating the camera or other entities.
      view.show_frame
      return true
    end
  end

  def test_nextFrame
    skip("Needs manual testing. Asynchronous callback.")
  end


  # ========================================================================== #
  # method Animation.pause
  # http://www.sketchup.com/intl/developer/docs/ourdoc/animation#pause

  def test_pause_api_example
    def pause
      # Insert handler code for whatever you need to do when it is paused.
    end
  end

  def test_pause
    # Needs Ruby API method to pause animations.
    skip(
      "Needs manual testing. Asynchronous callback. " <<
      "Missing API method to pause animation."
    )
  end


  # ========================================================================== #
  # method Animation.resume
  # http://www.sketchup.com/intl/developer/docs/ourdoc/animation#resume

  def test_resume_api_example
    def resume
      # Insert your handler code for whatever you need to do as you resume.
    end
  end

  def test_resume
    # Needs Ruby API method to resume animations.
    skip(
      "Needs manual testing. Asynchronous callback. " <<
      "Missing API method to resume animation."
    )
  end


  # ========================================================================== #
  # method Animation.stop
  # http://www.sketchup.com/intl/developer/docs/ourdoc/animation#stop

  def test_stop_api_example
    def stop
      # Insert your handler code for cleaning up after your animation.
    end
  end

  def test_stop
    # Test that stop is called when an animation is stopped by the API
    # by setting the view.animation = nil
    animation = TestAnimation.new(5)
    Sketchup.active_model.active_view.animation = animation
    Sketchup.active_model.active_view.animation = nil

    # This play_state will only be "STOPPED" if the stop method was
    # successfully called.
    assert_equal(:stopped, animation.play_state,
      "The stop method was not called as expected.")
  end


end # class
