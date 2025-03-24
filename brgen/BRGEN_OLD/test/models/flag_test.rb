# == Schema Information
#
# Table name: flags
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  flaggable_id   :integer
#  flaggable_type :string
#  created_at     :datetime
#  updated_at     :datetime
#

require 'test_helper'

class FlagTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

