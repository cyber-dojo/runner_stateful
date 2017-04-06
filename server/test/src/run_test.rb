require_relative 'test_base'

class RunTest < TestBase

  def self.hex_prefix; '58410'; end

  def hex_setup
    set_image_name "#{cdf}/gcc_assert"
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '8A9', %w(
  run returns red-amber-green traffic-light colour
  ) do
    kata_new
    avatar_new
    begin
      sss_run( { kata_id:kata_id })
      assert_colour 'red'
    ensure
      avatar_old
      kata_old
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B82', %w(
    files can be in sub-dirs of sandbox
  ) do
    kata_new
    avatar_new
    begin
      sss_run( { changed_files: {
        'cyber-dojo.sh' => ls_cmd,
        'a/hello.txt' => 'hello world'
      }})
      ls_files = ls_parse(stdout)
      salmon_uid = runner.user_id('salmon')
      assert_equal_atts('a', 'drwxr-xr-x', salmon_uid, runner.group, 4096, ls_files)
    ensure
      avatar_old
      kata_old
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '1DC', %w(
  run with valid kata_id that does not exist
    raises
  ) do
    kata_id = '0C67EC0416'
    assert_raises_kata_id(kata_id, '!exists')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '7FE', %w(
  run with kata_id that exists
    but invalid avatar_name
      raises
  ) do
    kata_new
    begin
      assert_raises_avatar_name(kata_id, 'scissors', 'invalid')
    ensure
      kata_old
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '951', %w(
  run with kata_id that exists
    and valid avatar_name that does not exist yet
      raises
  ) do
    kata_new
    begin
      assert_raises_avatar_name(kata_id, 'salmon', '!exists')
    ensure
      kata_old
    end
  end

  private

  def assert_raises_kata_id(kata_id, message)
    error = assert_raises(ArgumentError) {
      sss_run( { kata_id:kata_id })
    }
    assert_equal "kata_id:#{message}", error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_raises_avatar_name(kata_id, avatar_name, message)
    error = assert_raises(ArgumentError) {
      sss_run( {
            kata_id:kata_id,
        avatar_name:avatar_name
      })
    }
    assert_equal "avatar_name:#{message}", error.message
  end

end
