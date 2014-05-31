require "minitest/reporters"

module Aviator
class Test

  class SpecReporter < MiniTest::Reporters::SpecReporter

    private

    def pad_test(test)
      str = test.to_s.gsub(/(test_)/, '').gsub(/_/, ' ')
      pad("%-#{TEST_SIZE}s" % str, TEST_PADDING)[0..TEST_SIZE]
    end

    def print_info(e)
      print "       #{e.exception.class.to_s}:\n"
      e.message.each_line { |line| print_with_info_padding(line) }

      trace = filter_backtrace(e.backtrace)

      # TODO: Use the proper MiniTest way of customizing the filter
      trace.each { |line| print_with_info_padding(line) unless line =~ /\.rvm|gems|_run_anything/ }
    end

    def print_suite(suite)
      puts suite.name.gsub('::#', '#')
      @suites << suite
    end
  end


  class ProgressReporter < MiniTest::Reporters::ProgressReporter

    private

    def print_test_with_time(suite, test)
      total_time = Time.now - (runner.test_start_time || Time.now)
      suite_name = suite.name.gsub('::#', '#').gsub('::::', '::')
      test_name  = test.to_s.gsub(/test_\d+|_/, ' ').strip
      print(" %s %s (%.2fs)%s" % [suite_name, test_name, total_time, clr])
    end
  end

end
end

if running_in_ci
  MiniTest::Reporters.use! Aviator::Test::SpecReporter.new
else
  MiniTest::Reporters.use! Aviator::Test::ProgressReporter.new
end
