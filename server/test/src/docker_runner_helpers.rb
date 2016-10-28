require_relative './null_logger'
require 'json'

module DockerRunnerHelpers

  module_function

  def external_setup
    ENV[env_name('log')] = 'NullLogger'
    assert_equal 'NullLogger', log.class.name
    assert_equal 'ExternalSheller', shell.class.name
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def pulled?(image_name)
    runner.pulled?(image_name)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def pull(image_name)
    runner.pull(image_name)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def hello
    output, status = runner.hello(kata_id, avatar_name)
    @volume = volume_name if status == success
    [output, status]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def goodbye
    output, status = runner.goodbye(kata_id, avatar_name)
    @volume = nil if status == success
    [output, status]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def files(language_dir = 'gcc_assert')
    @files ||= load_files(language_dir)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def create_container
    refute_nil @image_name
    @cid = runner.create_container(@image_name, kata_id, avatar_name)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def execute(changed_files, max_seconds = 10, deleted_filenames = [])
    # Don't call this run (MiniTest uses that method name)
    cid = create_container
    runner.deleted_files(cid, deleted_filenames)
    runner.changed_files(cid, changed_files)
    runner.setup_home(cid)
    output, status = runner.run(cid, max_seconds)
    runner.remove_container(cid)
    [output, status]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def load_files(language_dir)
    dir = "/app/start_files/#{language_dir}"
    json = JSON.parse(IO.read("#{dir}/manifest.json"))
    @image_name = json['image_name']
    Hash[json['filenames'].collect { |filename|
      [filename, IO.read("#{dir}/#{filename}")]
    }]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def volume_exists?
    output, _ = assert_exec('docker volume ls')
    output.include? volume_name
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def runner; DockerRunner.new(self); end
  def success; 0; end
  def timed_out_and_killed; (timeout = 128) + (kill = 9); end
  def volume_name; 'cyber_dojo_' + kata_id + '_' + avatar_name; end
  def kata_id; test_id; end
  def avatar_name; 'salmon'; end

  def assert_exec(command)
    output, status = exec(command)
    assert_equal success, status, output
    [output, status]
  end

  def assert_execute(*args)
    output, status = execute(*args)
    assert_equal success, status, output
    [output, status]
  end

  def exec(command); shell.exec(command); end

  include Externals # for shell

end
