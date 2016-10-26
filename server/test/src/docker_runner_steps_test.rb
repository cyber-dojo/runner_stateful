
require_relative './lib_test_base'
require_relative './docker_runner_helpers'

class DockerRunnerStepsTest < LibTestBase

  def self.hex
    '4D87A'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '0C9',
  'newly created container has empty /sandbox owned by nobody:nogroup' do
    hello_avatar
    @image_name = 'cyberdojofoundation/ruby_mini_test'
    cid = create_container
    begin
      _, status = exec("docker exec #{cid} sh -c '[ -d #{sandbox} ]'")
      assert_equal 0, status, "#{sandbox} does not exist"
      _, status = exec("docker exec #{cid} sh -c '[ \"$(ls -A #{sandbox})\" ]'")
      assert_equal 1, status, "#{sandbox} is not empty"
      output, _ = assert_exec("docker exec #{cid} sh -c 'stat -c \"%U\" #{sandbox}'")
      assert_equal 'nobody', (user_name = output.strip)
      output, _ = assert_exec("docker exec #{cid} sh -c 'stat -c \"%G\" #{sandbox}'")
      assert_equal 'nogroup', (group_name = output.strip)
    ensure
      # not calling runner.run so have to delete container
      assert_exec("docker rm --force #{cid}")
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '385',
  'deleted files are removed and all previous files still exist' do
    hello_avatar
    files['cyber-dojo.sh'] = 'ls'

    ls_output, _ = assert_execute(files)
    before_filenames = ls_output.split

    ls_output, _ = assert_execute({}, max_seconds = 10, [ 'makefile' ])
    after_filenames = ls_output.split

    deleted_filenames = before_filenames - after_filenames
    assert_equal [ 'makefile' ], deleted_filenames
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '232',
  'new files are added and all previous files still exist' do
    hello_avatar

    files['cyber-dojo.sh'] = 'ls'
    ls_output, _ = assert_execute(files)
    before_filenames = ls_output.split

    files = { 'newfile.txt' => 'hello world' }
    ls_output, _ = assert_execute(files)
    after_filenames = ls_output.split

    new_filenames = after_filenames - before_filenames
    assert_equal 5, before_filenames.size
    assert_equal 6, after_filenames.size
    assert_equal [ 'newfile.txt' ], new_filenames
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '4E8',
  "unchanged files still exist and don't get touched at all" do
    hello_avatar
    files['cyber-dojo.sh'] = 'ls -el'

    before_ls, _ = assert_execute(files)
    after_ls, _ = assert_execute({})

    assert_equal before_ls, after_ls
    assert_equal 6, before_ls.split("\n").size
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9A7',
  'a changed file is resaved and its size and time-stamp updates' do
    hello_avatar

    files['cyber-dojo.sh'] = 'ls -el | tail -n +2'
    ls_output, _ = assert_execute(files)
    # each line looks like this...
    # -rwxr-xr-x 1 nobody root 19 Sun Oct 23 19:15:35 2016 cyber-dojo.sh
    before = ls_parse(ls_output)
    assert_equal 5, before.size

    sleep 2

    hiker_h = files['hiker.h']
    extra = '//hello'
    files = { 'hiker.h' => hiker_h + extra }
    ls_output, _ = assert_execute(files)
    after = ls_parse(ls_output)

    assert_equal before.keys, after.keys
    before.keys.each do |filename|
      was = before[filename]
      now = after[filename]
      same = lambda { |name| assert_equal was[name], now[name] }
      same.call(:permissions)
      same.call(:user)
      same.call(:group)
      if filename == 'hiker.h'
        refute_equal now[:time_stamp], was[:time_stamp]
        assert_equal now[:size], was[:size] + extra.size
      else
        same.call(:time_stamp)
        same.call(:size)
      end
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  private

  include DockerRunnerHelpers

  def ls_parse(ls_output)
    # each line looks like this...
    # -rwxr-xr-x 1 nobody root 19 Sun Oct 23 19:15:35 2016 cyber-dojo.sh
    # 0          1 2      3    4  5   6   7  8        9    10
    Hash[ls_output.split("\n").collect { |line|
      info = line.split
      filename = info[10]
      [filename, {
        permissions: info[0],
               user: info[2],
              group: info[3],
               size: info[4].to_i,
         time_stamp: info[8],
      }]
    }]
  end

  def sandbox; '/sandbox'; end

end