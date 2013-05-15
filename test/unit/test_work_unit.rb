require 'test_helper'

class WorkUnitTest < Test::Unit::TestCase

  context "A WorkUnit" do
    
    setup do
      @unit = CloudCrowd::WorkUnit.make!
      @job = @unit.job
    end
    
    subject { @unit }
    
    should belong_to( :job )
    
    should validate_presence_of( :job_id )
    should validate_presence_of( :status )
    should validate_presence_of( :input  )
    should validate_presence_of( :action )
    
    should "know if its done" do
      assert !@unit.complete?
      @unit.status = SUCCEEDED
      assert @unit.complete?
      @unit.status = FAILED
      assert @unit.complete?
    end
    
    should "have JSON that includes job attributes" do
      job = Job.make!
      unit_data = JSON.parse(job.work_units.first.to_json)
      assert unit_data['job_id'] == job.id
      assert unit_data['action'] == job.action
      assert JSON.parse(job.inputs).include? unit_data['input']
    end
    
    should "be able to retry, on failure" do
      @unit.update_attribute :worker_pid, 7337
      assert @unit.attempts == 0
      @unit.fail('oops', 10)
      assert @unit.worker_pid == nil
      assert @unit.attempts == 1
      assert @unit.processing?
      @unit.fail('oops again', 10)
      assert @unit.attempts == 2
      assert @unit.processing?
      assert @unit.job.processing?
      @unit.fail('oops one last time', 10)
      assert @unit.attempts == 3
      assert @unit.failed?
      assert @unit.job.any_work_units_failed?
    end

    should "create with standard priority by default" do
      assert_equal 1, @unit.priority_rank
    end

    should "sort work by priority" do
      10.downto(0).each do | rank |
        CloudCrowd::WorkUnit.make!({:priority_rank=>rank})
      end
      assert_equal 0, WorkUnit.ordered_by_priority.first.priority_rank
    end

    should "reserve lowest priority first" do
      3.downto(0).each do | rank |
        ( 0...100 ).each do
          CloudCrowd::WorkUnit.make!({ :priority_rank=>rank })
        end
      end
      assert reservation = WorkUnit.reserve_available( :limit => 10, :conditions => 'action="graphics_magick"'  )
      units = WorkUnit.reserved(reservation)
      assert_equal 10, units.length
      units.each do |wu|
        assert_equal 0, wu.priority_rank
      end
    end

  end

end
