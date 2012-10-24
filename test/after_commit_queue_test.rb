require 'test_helper'

class AfterCommitQueueTest < ActiveSupport::TestCase
  def setup
    @server = Server.new
  end

  test "run methods after transaction is committed" do
    assert !@server.started

    @server.transaction do
      @server.start!
      assert !@server.started
    end

    assert @server.started
  end

  test "run blocks after transaction is committed" do
    @server.start!
    assert !@server.meditating

    @server.transaction do
      @server.crash!
      assert !@server.meditating
    end

    assert @server.meditating
  end

  test "clear queue after methods from are called" do
    @server.start!
    @server.started = false

    @server.stop!
    assert !@server.started
    assert @server.stopped
  end

  test "clears queue after rollback" do
    assert !@server.started

    Server.transaction do
      @server.start!
      assert !@server.started
      raise ActiveRecord::Rollback
    end
    
    assert @server.__send__(:_after_commit_queue).empty?
    assert !@server.started
  end
end
