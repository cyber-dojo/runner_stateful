require_relative 'test_base'

class AvatarTest < TestBase

  def self.hex_prefix; '20A7A'; end

  def hex_setup
    set_image_name 'cyberdojofoundation/gcc_assert'
    new_kata
  end

  def hex_teardown
    old_kata
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # positive test case
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '75E',
  "before new_avatar avatar does not exist",
  "after new_avatar it does exist" do
    refute avatar_exists?
    new_avatar
    assert avatar_exists?
    old_avatar
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # negative tests cases: new_avatar
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B20',
  'new_avatar with an invalid kata_id raises' do
    assert_method_raises(:new_avatar, invalid_kata_ids, 'salmon', 'kata_id:invalid')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '7C4',
  'new_avatar with non-existent kata_id raises' do
    kata_id = '42CF187311'
    assert_method_raises(:new_avatar, kata_id, 'salmon', 'kata_id:!exists')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '35D',
  'new_avatar with existing kata_id but invalid avatar_name raises' do
    assert_method_raises(:new_avatar, kata_id, invalid_avatar_names, 'avatar_name:invalid')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '119',
  'new_avatar with existing kata_id but avatar_name that already exists raises' do
    new_avatar({ avatar_name:'salmon' })
    assert_method_raises(:new_avatar, kata_id, 'salmon', 'avatar_name:exists')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # negative test cases: old_avatar
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2A8',
  'old_avatar with invalid kata_id raises' do
    assert_method_raises(:old_avatar, invalid_kata_ids, 'salmon', 'kata_id:invalid')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E35',
  'old_avatar with non-existent kata_id raises' do
    kata_id = '92BB3FE5B6'
    assert_method_raises(:old_avatar, kata_id, 'salmon', 'kata_id:!exists')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E5D',
  'old_avatar with existing kata_id but invalid avatar_name raises' do
    assert_method_raises(:old_avatar, kata_id, invalid_avatar_names, 'avatar_name:invalid')
  end

  test 'D6F',
  'old_avatar with existing kata_id but avatar_name that does not exist raises' do
    assert_method_raises(:old_avatar, kata_id, 'salmon', 'avatar_name:!exists')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # negative test case: user_id
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A10',
  'user_id with invalid avatar_name raises' do
    invalid_avatar_names.each do |invalid_avatar_name|
      error = assert_raises(ArgumentError) {
        runner.user_id(invalid_avatar_name)
      }
      assert_equal 'avatar_name:invalid', error.message
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # negative test case: user_id
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '0C8',
  'sandbox_path with invalid avatar_name raises' do
    invalid_avatar_names.each do |invalid_avatar_name|
      error = assert_raises(ArgumentError) {
        runner.sandbox_path(invalid_avatar_name)
      }
      assert_equal 'avatar_name:invalid', error.message
    end
  end


  private

  def assert_method_raises(method, kata_ids, avatar_names, message)
    [*kata_ids].each do |kata_id|
      [*avatar_names].each do |avatar_name|
        error = assert_raises(ArgumentError) {
          self.send(method, {
                kata_id:kata_id,
            avatar_name:avatar_name
          })
        }
      assert_equal message, error.message
      end
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def invalid_avatar_names
    [
      nil,
      Object.new,
      [],
      '',
      'scissors'
    ]
  end

end
