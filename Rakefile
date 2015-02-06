require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rake'
require 'logger'
require 'rake/clean'
require 'rubygems/package_task'

desc 'Package gem'
gemtask = Gem::PackageTask.new(Gem::Specification.load('warthog.gemspec')) do |package|
  package.package_dir = 'pkg'
  package.need_zip = true
  package.need_tar = true
end

directory gemtask.package_dir

CLEAN.include(gemtask.package_dir)
