require 'sketchup.rb'
require 'taskbar_progress.rb'

class TaskbarProgress
module Test

  def self.do_some_work(total = 1000)
    progress = TaskbarProgress.new
    model = Sketchup.active_model
    entities = model.active_entities
    entities.clear!
    total.times { |i|
      progress.set_value(i, total)
      edge = entities.add_line([0,0,i], [10,0,i])
      edge.material = 'red'

      if i == 400
        progress.set_state(TaskbarProgress::PAUSED)
        UI.messagebox('Paused for a bit! *phew!*')
        progress.set_state(TaskbarProgress::NORMAL)
      end

      if i == 800
        progress.set_state(TaskbarProgress::ERROR)
        UI.messagebox('Oh no! Not an error! What to do?!')
        progress.set_state(TaskbarProgress::INDETERMINATE)
        sleep(5)
        progress.set_state(TaskbarProgress::NORMAL)
      end
    }
    progress.set_state(TaskbarProgress::NOPROGRESS)
    nil
  end


  def self.clean_up
    model = Sketchup.active_model
    entities = model.active_entities

    TaskbarProgress.new.each(entities.to_a) { |entity|
      entity.erase!
    }

    nil
  end

  unless file_loaded?(__FILE__)
    menu = UI.menu("Plugins")
    menu.add_item("Test TaskbarProgress") {
      self.do_some_work
    }

    file_loaded(__FILE__)
  end

end # module
end # class
