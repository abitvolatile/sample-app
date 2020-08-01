require 'thor'
require 'thor/group'

case ARGV.first
when 'version', '-v', '--version'
  puts Gem.loaded_specs['spree_cmd'].version
when 'extension'
  ARGV.shift
  require 'spree_cmd/extension'
  SpreeCmd::Extension.start
end
