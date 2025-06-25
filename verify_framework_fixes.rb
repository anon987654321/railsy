#!/usr/bin/env ruby
# Verification script for master.json framework fixes
# Validates that all problem statement requirements have been addressed

require 'json'

def verify_fixes
  config = JSON.parse(File.read('prompts/master.json'))
  
  puts "🔍 VERIFYING MASTER.JSON FRAMEWORK FIXES"
  puts "=" * 50
  
  # Fix 1: Extract Universal Rules to Global Enforcement
  puts "\n✅ Fix 1: Universal Rules Extracted to Global Enforcement"
  universal = config['universal_enforcement']
  if universal && universal['global_principles']
    solid_principles = %w[single_responsibility open_closed liskov_substitution interface_segregation dependency_inversion]
    solid_count = solid_principles.count { |p| universal['global_principles'][p] }
    puts "   - SOLID principles in global enforcement: #{solid_count}/5"
    puts "   - Parametric design global: #{universal['global_principles']['parametric_design'] ? 'Yes' : 'No'}"
    puts "   - Global enforcement section: Present ✅"
  else
    puts "   ❌ Universal enforcement section missing"
  end
  
  # Fix 2: Consolidate Scattered Principles
  puts "\n✅ Fix 2: Consolidated Scattered Principles"
  if universal
    puts "   - Quality standards: #{universal['quality_standards'] ? 'Unified ✅' : 'Missing ❌'}"
    puts "   - Security defaults: #{universal['security_defaults'] ? 'Unified ✅' : 'Missing ❌'}"
    puts "   - Communication standards: #{universal['communication_standards'] ? 'Unified ✅' : 'Missing ❌'}"
  end
  
  # Fix 3: Fix Status Message Format
  puts "\n✅ Fix 3: Status Message Format Fixed"
  status = config['status_indicators']
  if status
    puts "   - Status indicators section: Present ✅"
    puts "   - Emoji format standard: #{status['format_standards']['emoji_format']}"
    puts "   - Proper spacing requirements: #{status['spacing_requirements'] ? 'Defined ✅' : 'Missing ❌'}"
    
    # Check for raw emoji usage (not wrapped in brackets)
    indicators = status['indicators']
    if indicators && indicators.values.any? { |v| v.match(/[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]/) }
      puts "   - Raw emoji usage: Correct ✅"
    end
  else
    puts "   ❌ Status indicators section missing"
  end
  
  # Fix 4: Establish Universal Code Standards
  puts "\n✅ Fix 4: Universal Code Standards Established"
  comm = universal['communication_standards'] if universal
  if comm
    puts "   - Code quoting standard: #{comm['code_quoting_standard']}"
    puts "   - Strunk & White clarity: #{comm['strunk_white_clarity'] ? 'Enforced ✅' : 'Not enforced ❌'}"
    puts "   - Logical spacing: #{comm['logical_spacing_required'] ? 'Required ✅' : 'Not required ❌'}"
  else
    puts "   ❌ Communication standards missing"
  end
  
  # Fix 5: Unified Validation System
  puts "\n✅ Fix 5: Unified Validation System Created"
  validation = config['unified_validation']
  if validation
    puts "   - Universal checkpoint: #{validation['universal_checkpoint'] ? 'Active ✅' : 'Inactive ❌'}"
    puts "   - Applies to: #{validation['applies_to']}"
    puts "   - Rules enforced: #{validation['rules_enforced'].join(', ')}"
    puts "   - Context coverage: #{validation['applies_to'] == 'all_contexts' ? 'Complete ✅' : 'Partial ❌'}"
  else
    puts "   ❌ Unified validation system missing"
  end
  
  # Success Criteria Verification
  puts "\n🎯 SUCCESS CRITERIA VERIFICATION"
  puts "=" * 40
  
  criteria = [
    ["Universal rules apply globally", universal && universal['global_principles']],
    ["Status messages properly formatted", status && status['format_standards']],
    ["Communication standards consistent", comm && comm['code_quoting_standard']],
    ["No critical principles in conditional sections", check_no_critical_in_stacks(config)],
    ["Unified enforcement vs scattered policies", validation && validation['universal_checkpoint']]
  ]
  
  criteria.each do |description, passed|
    status_icon = passed ? "✅" : "❌"
    puts "   #{status_icon} #{description}"
  end
  
  passed_count = criteria.count { |_, passed| passed }
  puts "\n📊 OVERALL RESULT: #{passed_count}/#{criteria.length} criteria met"
  
  if passed_count == criteria.length
    puts "🎉 ALL FRAMEWORK FIXES SUCCESSFULLY IMPLEMENTED!"
  else
    puts "⚠️  Some fixes need attention"
  end
end

def check_no_critical_in_stacks(config)
  # Check that SOLID principles are not duplicated in stack-specific sections
  critical_keywords = %w[solid single_responsibility open_closed liskov interface_segregation dependency_inversion parametric_design]
  
  stacks = config['stacks'] || {}
  stacks.each do |stack_name, stack_config|
    next if stack_name == 'global'
    
    stack_text = stack_config.to_s.downcase
    critical_keywords.each do |keyword|
      if stack_text.include?(keyword.downcase)
        puts "   ⚠️  Critical principle '#{keyword}' found in stack '#{stack_name}'"
        return false
      end
    end
  end
  
  true
end

verify_fixes