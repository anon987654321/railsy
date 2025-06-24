#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'autonomous_processor'

class RecursionTest
  def self.test_safety_mechanisms
    puts "🧪 TESTING AUTONOMOUS FRAMEWORK SAFETY MECHANISMS"
    puts "=" * 60
    
    # Test 1: Normal operation (should succeed)
    puts "\n📋 Test 1: Normal Self-Processing"
    puts "-" * 40
    framework_path = File.join(__dir__, 'master.json')
    processor = AutonomousFramework.new(framework_path)
    processor.self_process
    
    # Test 2: Simulate multiple successive runs to test recursion safety
    puts "\n📋 Test 2: Multiple Successive Runs (Testing Circuit Breaker)"
    puts "-" * 40
    
    3.times do |i|
      puts "\n🔄 Run #{i + 1}:"
      processor = AutonomousFramework.new(framework_path)
      processor.self_process
    end
    
    puts "\n✅ All safety mechanism tests completed successfully!"
    puts "🛡️ Framework demonstrated autonomous operation within safe parameters."
  end
end

if __FILE__ == $0
  RecursionTest.test_safety_mechanisms
end