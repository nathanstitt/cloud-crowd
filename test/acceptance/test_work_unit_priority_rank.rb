require 'test_helper'

# A Worker Daemon needs to be running to perform this integration test.
class WorkUnitPriorityRankTest < Test::Unit::TestCase

  context "Many WorkUnits with Priority" do

    setup do 
      clear_database!
    end

    should "start on highest priority first" do

      ids = []

      10.downto(0).each do | rank |

        browser = Rack::Test::Session.new(Rack::MockSession.new(CloudCrowd::Server))

        browser.post '/jobs', :job => {
          'action'  => 'word_count',
          'inputs'  => ["file://#{File.expand_path(__FILE__)}"],
          'priority_rank' => rank,
          'options' => {}
        }.to_json

        assert browser.last_response.ok?

        ids << JSON.parse(browser.last_response.body)['id']

      end

      assert reservation = WorkUnit.reserve_available( :limit => 10, :conditions => 'action="word_count"'  )
      units = WorkUnit.reserved(reservation)
      assert_equal (0..9).to_a, units.map(&:priority_rank)

    end
  end

end
