# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'warthog/version'
require 'warthog/about'

Gem::Specification.new do |s|
  s.name                      = Warthog::ME.to_s
  s.version                   = Warthog::VERSION
  s.platform                  = Gem::Platform::RUBY
  s.authors                   = "Gerardo López-Fernádez"
  s.email                     = 'gerir@evernote.com'
  s.homepage                  = 'https://github.com/evernote/ops-warthog'
  s.summary                   = "A10 REST poker"
  s.description               = "POkes A10 SLBs with a RESTick"
  s.license                   = "Apache License, Version 2.0"
  s.required_rubygems_version = ">= 1.3.5"

  s.add_dependency('httparty')
  s.add_dependency('etc')

  s.files        = Dir['lib/**/*.rb'] + Dir['bin/*'] + %w(LICENSE README.md)
  s.executables  = %w(warthog)
  s.require_path = 'lib'
end
