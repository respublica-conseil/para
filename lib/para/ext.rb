module Para
  # References all framework extensions to make our code work well with other
  # libraries.
  #
  # One goal is to have the minimum of them, but sometimes, without them, we
  # may need to make our own code dirty
  #
  module Ext
  end
end

require 'para/ext/paperclip'
require 'para/ext/deep_cloneable'
require 'para/ext/active_job_status'
require 'para/ext/active_record_nested_attributes'
require 'para/ext/request_iframe_xhr'
