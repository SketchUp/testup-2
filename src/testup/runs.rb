#-------------------------------------------------------------------------------
#
# Copyright 2013-2016 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'testup/app_files'


module TestUp
module Runs

  extend AppFiles

  def self.all
    TestUp.settings[:saved_runs] ||= []
    TestUp.settings[:saved_runs]
  end

  def self.current
    TestUp.settings[:current_run]
  end

  def self.save_run(run)
    runs = self.all
    runs << run
    # TODO(thomthom): Copy the run file to a dedicated folder?
    TestUp.settings[:saved_runs] = runs
  end

  def self.add
    run_config_file = self.select_config
    return unless run_config_file
    prompts = ['Title']
    defaults = ['']
    result = UI.inputbox(prompts, defaults, 'Give the Run title')
    return unless result
    title = result[0]
    # TODO(thomthom): Check for an existing run on the same name.
    self.save_run([title, run_config_file])
  end

  def self.remove
    runs = self.all
    if runs.empty?
      UI.messagebox('There are no saved test runs.')
      return
    end
    run_titles = runs.map { |run| run.first }.sort
    run_options = run_titles.join('|')
    prompts = ['Remove Run:']
    defaults = [run_titles.first]
    options = [run_options]
    result = UI.inputbox(prompts, defaults, options, 'Delete a Run Replay')
    return unless result
    title = result[0]
    unless run_titles.include?(title)
      UI.messagebox('There are no saved test runs.')
      return
    end
    runs.delete_if { |run| run.first == title }
    TestUp.settings[:saved_runs] = runs
  end

  def self.select_config
    title = 'Open TestUp Run Log'
    file_filter = 'TestUp Run Logs (*.run)|*.run;||'
    result = UI.openpanel(title, log_path, file_filter)
    result ? File.expand_path(result) : result
  end

  def self.read_config(run_file)
    JSON.parse(File.read(run_file), symbolize_names: true)
  end

  def self.set_current
    runs = self.all
    run_titles = runs.map { |run| run.first }.sort
    run_options = ['[None]'].concat(run_titles).join('|')
    prompts = ['Replay-Run:']
    defaults = [self.current || '[None]']
    options = [run_options]
    result = UI.inputbox(prompts, defaults, options, 'Pick what run to Replay')
    return unless result
    title = result[0]
    if title == '[None]'
      TestUp.settings[:current_run] = nil
    else
      run = runs.find { |r| r.first == title }
      TestUp.settings[:current_run] = run.first
    end
  end

  def self.rerun_current
    # TODO(thomthom): Avoid having the user set this manually.
    if TestUp.settings[:run_in_gui]
      UI.messagebox('TestUp must be set to run in Console mode for re-runs to work.')
      return
    end
    runs = self.all
    run_title = self.current
    run = runs.find { |r| r.first == run_title }
    unless run
      UI.messagebox("Unable to locate .run file for: #{run_title}")
      return
    end
    run_file = run[1]
    p run
    puts "runfile: #{run_file}"
    p runs
    # Load the Run configuration.
    run_config = self.read_config(run_file)
    # TODO(thomthom): This duplicate code in run_tests_gui. Refactor and reuse.
    options = {
        seed: run_config[:seed]
    }
    testsuite = 'Re-run' # TODO(thomthom): get from saved run.
    tests = run_config[:tests]
    # Execute the tests!
    TestUp.run_tests(tests, testsuite, options)
  end

end # module
end # module TestUp
