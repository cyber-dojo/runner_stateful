require_relative './runner_test_base'

class DockerRunnerKataTest < RunnerTestBase

  def self.hex_prefix; 'FB0D4'; end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'CC8',
  'when image_name is valid and has not been pulled',
  'then new_kata(kata_id, image_name) pulls it and succeeds' do
    @image_name = 'busybox'
    exec("docker rmi #{@image_name}", logging = false)
    refute docker_pulled?(@image_name)
    _,_,status = new_kata
    begin
      assert status
      assert docker_pulled?(@image_name)
    ensure
      old_kata
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '5E7',
  'when image_name is valid has been pulled',
  'then new_kata(kata_id, image_name) succeeds' do
    @image_name = 'busybox'
    exec("docker pull #{@image_name}", logging = false)
    assert docker_pulled?(@image_name)
    _,_,status = new_kata
    begin
      assert status
      assert docker_pulled?(@image_name)
    ensure
      old_kata
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AED',
  'when image_name is invalid then new_kata(kata_id, image_name) fails with not-found' do
    bad_image_name = '123/123'
    runner.logging_off
    raised = assert_raises(DockerRunnerError) { runner.new_kata(kata_id, bad_image_name) }
    refute_equal 0, raised.status
    assert_equal [
      "Using default tag: latest",
      "Pulling repository docker.io/#{bad_image_name}"
    ].join("\n"), raised.stdout
    assert_equal "Error: image #{bad_image_name}:latest not found", raised.stderr
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'FA0',
  "old_kata removes all avatar's volumes" do
    @image_name = 'busybox'
    new_kata
    runner.new_avatar(kata_id, 'salmon')
    runner.new_avatar(kata_id, 'lion')
    assert_equal [ "cyber_dojo_#{kata_id}_lion", "cyber_dojo_#{kata_id}_salmon" ], volume_names.sort
    old_kata
    assert_equal [], volume_names.sort
  end

  private

  def docker_pulled?(image_name)
    image_names.include?(image_name)
  end

  def image_names
    lines = assert_exec('docker images')[0].split("\n")
    lines.shift # REPOSITORY TAG IMAGE ID CREATED SIZE
    lines.collect { |line| line.split[0] }
  end

  def volume_names
    stdout,_ = assert_exec("docker volume ls --quiet --filter 'name=cyber_dojo_#{kata_id}'")
    stdout.strip.split("\n")
  end

end

