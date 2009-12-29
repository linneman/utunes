class BundleComment < ActiveRecord::Base
  belongs_to :bundle
  belongs_to :user
end
