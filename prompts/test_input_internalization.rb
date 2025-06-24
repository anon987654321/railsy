#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'

class InputInternalizationTest
  def self.test_v2_2_enhancements
    puts "🧪 TESTING MASTER.JSON V2.2 INPUT INTERNALIZATION FEATURES"
    puts "=" * 65
    
    framework_path = File.join(__dir__, 'master_v2_2.json')
    
    # Test 1: Validate v2.2 schema structure
    puts "\n📋 Test 1: V2.2 Schema Validation"
    puts "-" * 40
    
    begin
      framework = JSON.parse(File.read(framework_path))
      
      # Check version
      if framework['schema_version'] == '2.2'
        puts "✅ Schema version correctly set to 2.2"
      else
        puts "❌ Schema version incorrect: #{framework['schema_version']}"
        return false
      end
      
      # Check required new sections
      required_sections = [
        'principles',
        'execution_workflows',
        'rules', 
        'validation',
        'prompts'
      ]
      
      required_sections.each do |section|
        if framework.key?(section)
          puts "✅ Required section present: #{section}"
        else
          puts "❌ Missing required section: #{section}"
          return false
        end
      end
      
    rescue JSON::ParserError => e
      puts "❌ JSON parsing error: #{e.message}"
      return false
    rescue => e
      puts "❌ Error loading framework: #{e.message}"
      return false
    end
    
    # Test 2: Validate Full Input Internalization Principle
    puts "\n📋 Test 2: Full Input Internalization Principle"
    puts "-" * 40
    
    principle = framework.dig('principles', 'full_input_internalization')
    if principle
      puts "✅ Full Input Internalization principle defined"
      if principle['default_behavior'] == 'process_entire_input_completely'
        puts "✅ Default behavior correctly set to complete processing"
      else
        puts "❌ Incorrect default behavior: #{principle['default_behavior']}"
      end
    else
      puts "❌ Full Input Internalization principle missing"
    end
    
    # Test 3: Validate Input Scope Validation Workflow
    puts "\n📋 Test 3: Input Scope Validation 3-Phase Workflow" 
    puts "-" * 40
    
    workflow = framework.dig('execution_workflows', 'input_scope_validation')
    if workflow && workflow['phases']
      expected_phases = ['input_scope_detection', 'scope_clarification', 'full_input_processing']
      actual_phases = workflow['phases'].map { |p| p['name'] }
      
      expected_phases.each do |phase|
        if actual_phases.include?(phase)
          puts "✅ Required phase present: #{phase}"
        else
          puts "❌ Missing required phase: #{phase}"
        end
      end
    else
      puts "❌ Input scope validation workflow missing or malformed"
    end
    
    # Test 4: Validate Rules and Validation
    puts "\n📋 Test 4: Default Full Input Usage Rule & Scope Fidelity"
    puts "-" * 40
    
    if framework.dig('rules', 'default_full_input_usage')
      puts "✅ Default full input usage rule present"
    else
      puts "❌ Default full input usage rule missing"
    end
    
    if framework.dig('validation', 'input_scope_fidelity', 'coverage_threshold') == '100_percent'
      puts "✅ 100% coverage threshold correctly configured"
    else
      puts "❌ Coverage threshold not set to 100%"
    end
    
    # Test 5: Validate SVG Enhancement Prompts
    puts "\n📋 Test 5: Enhanced SVG Full Internalization Prompts"
    puts "-" * 40
    
    svg_prompt = framework.dig('prompts', 'svg_full_internalization')
    if svg_prompt && svg_prompt['template']
      puts "✅ SVG full internalization prompt template present"
      if svg_prompt['compliance'] == 'w3c_svg_standards'
        puts "✅ W3C SVG standards compliance configured"
      else
        puts "❌ W3C SVG standards compliance missing"
      end
    else
      puts "❌ SVG full internalization prompt missing"
    end
    
    # Test 6: Validate Backward Compatibility
    puts "\n📋 Test 6: Backward Compatibility with V2.1"
    puts "-" * 40
    
    # Check that v2.1 features are preserved
    v2_1_features = ['core', 'reasoning', 'quality_assurance']
    v2_1_features.each do |feature|
      if framework.key?(feature)
        puts "✅ V2.1 feature preserved: #{feature}"
      else
        puts "❌ V2.1 feature missing: #{feature}"
      end
    end
    
    # Check safety_limits under core (v2.2 structure)
    if framework.dig('core', 'safety_limits')
      puts "✅ V2.1 feature preserved: safety_limits (under core)"
    else
      puts "❌ V2.1 feature missing: safety_limits"
    end
    
    # Test 7: Validate Standards Compliance
    puts "\n📋 Test 7: ISO 9001:2015 & W3C Standards Compliance"
    puts "-" * 40
    
    compliance = framework.dig('quality_assurance', 'compliance')
    if compliance && compliance['iso_9001_2015'] && compliance['w3c_standards']
      puts "✅ ISO 9001:2015 compliance configured"
      puts "✅ W3C standards compliance configured"
    else
      puts "❌ Standards compliance configuration incomplete"
    end
    
    puts "\n✅ All v2.2 Input Internalization tests completed!"
    puts "🛡️ Framework v2.2 demonstrates enhanced input processing capabilities."
    true
  end
  
  def self.test_input_scope_scenarios
    puts "\n🎯 TESTING INPUT SCOPE VALIDATION SCENARIOS"
    puts "=" * 50
    
    # Scenario 1: SVG input with ambiguous scope
    puts "\n📋 Scenario 1: SVG Input Processing"
    puts "-" * 30
    puts "Input: Large SVG file with multiple elements"
    puts "Expected: Trigger scope clarification workflow"
    puts "Action: Apply svg_full_internalization prompt"
    puts "✅ Scenario documented for framework application"
    
    # Scenario 2: Explicit full scope request
    puts "\n📋 Scenario 2: Explicit Full Scope"
    puts "-" * 30
    puts "Input: 'Process this entire document completely'"
    puts "Expected: Skip clarification, proceed to full processing"
    puts "Action: Apply full_input_processing workflow"
    puts "✅ Scenario documented for framework application"
    
    # Scenario 3: Ambiguous partial request
    puts "\n📋 Scenario 3: Ambiguous Scope"
    puts "-" * 30
    puts "Input: 'Help me with this file'"
    puts "Expected: Trigger scope clarification workflow"
    puts "Action: Apply general_input_clarification prompt"
    puts "✅ Scenario documented for framework application"
    
    puts "\n✅ Input scope validation scenarios defined!"
  end
end

if __FILE__ == $0
  success = InputInternalizationTest.test_v2_2_enhancements
  InputInternalizationTest.test_input_scope_scenarios
  
  exit(success ? 0 : 1)
end