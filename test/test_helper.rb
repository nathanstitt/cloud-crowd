ENV['RACK_ENV'] = 'test'
require 'rubygems'

here = File.dirname(__FILE__)
require File.expand_path(here + "/../lib/cloud-crowd")
CloudCrowd.configure(here + '/config/config.yml')

unless File.exists?( here+'/cloud_crowd_test.db')
  CloudCrowd.configure_database("#{here}/config/database.yml", false)
  require 'cloud_crowd/schema.rb'
end

CloudCrowd.configure_database(here + '/config/database.yml')


require 'faker'
require 'sham'
require 'rack/test'
require 'shoulda'
require 'machinist/active_record'
require 'mocha/setup'
require "#{CloudCrowd::ROOT}/test/blueprints.rb"

class Test::Unit::TestCase
  include CloudCrowd

  def clear_database!
    db = SQLite3::Database.new "#{File.dirname(__FILE__)}/cloud_crowd_test.db"
    db.execute( "SELECT name FROM sqlite_master WHERE type='table'" ) do | table, unused |
      unless 'schema_migrations' == table
        db.execute("delete from #{table}")
      end
    end
  end

end
