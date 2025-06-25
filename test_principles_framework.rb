#!/usr/bin/env ruby
# Test suite for validating consolidated principles framework
# Tests rule nesting bottleneck fixes and universal application

require 'json'
require 'test/unit'

class PrinciplesFrameworkTest < Test::Unit::TestCase
  def setup
    @config = JSON.parse(File.read('prompts/master.json'))
  end

  def test_universal_principles_exist
    assert @config.key?('principles'), "Universal principles section must exist"
    assert_instance_of Array, @config['principles']
    assert @config['principles'].length > 0, "Principles array must not be empty"
  end

  def test_enforcement_section_exists
    assert @config.key?('enforcement'), "Enforcement section must exist"
    enforcement = @config['enforcement']
    
    assert enforcement.key?('universal_application'), "Universal application must be defined"
    assert_equal true, enforcement['universal_application']['enabled']
    assert_equal 'all_workflows_and_stacks', enforcement['universal_application']['scope']
  end

  def test_solid_principles_in_universal_scope
    principles = @config['principles']
    solid_principles = principles.select { |p| p['id'].start_with?('solid_') }
    
    assert_equal 5, solid_principles.length, "All 5 SOLID principles must be present"
    
    expected_solid = [
      'solid_single_responsibility',
      'solid_open_closed', 
      'solid_liskov_substitution',
      'solid_interface_segregation',
      'solid_dependency_inversion'
    ]
    
    actual_solid = solid_principles.map { |p| p['id'] }
    assert_equal expected_solid.sort, actual_solid.sort
    
    # All SOLID principles must have universal scope
    solid_principles.each do |principle|
      assert_equal 'universal', principle['scope']
    end
  end

  def test_security_principles_in_universal_scope
    principles = @config['principles']
    security_principles = principles.select do |p| 
      ['secure_by_default', 'input_validation', 'output_sanitization', 'defensive_programming'].include?(p['id'])
    end
    
    assert security_principles.length >= 4, "Security principles must be universally available"
    
    security_principles.each do |principle|
      assert_equal 'universal', principle['scope']
    end
  end

  def test_communication_principles_in_universal_scope
    principles = @config['principles']
    communication_principles = principles.select do |p|
      ['ultraminimal_communication', 'strunk_white_clarity'].include?(p['id'])
    end
    
    assert_equal 2, communication_principles.length, "Communication principles must be universally available"
    
    communication_principles.each do |principle|
      assert_equal 'universal', principle['scope']
    end
  end

  def test_stack_inheritance_from_global
    stacks = @config['stacks']
    
    # All stacks except global should inherit from global
    stacks.each do |stack_name, stack_config|
      next if stack_name == 'global'
      
      assert stack_config.key?('inherits_from'), "Stack #{stack_name} must inherit from global"
      assert_equal 'global', stack_config['inherits_from']
    end
  end

  def test_global_stack_inherits_universal_principles
    global_stack = @config['stacks']['global']
    assert global_stack.key?('inherits_principles'), "Global stack must inherit universal principles"
    assert_equal 'all_universal_principles', global_stack['inherits_principles']
  end

  def test_stack_rules_extend_principles
    stacks = @config['stacks']
    
    stacks.each do |stack_name, stack_config|
      rules = stack_config['rules'] || []
      
      rules.each do |rule|
        if rule.key?('extends')
          assert_instance_of Array, rule['extends'], "Extends property must be an array"
          
          # Verify that extended principles exist in universal principles
          universal_principle_ids = @config['principles'].map { |p| p['id'] }
          rule['extends'].each do |extended_id|
            assert_includes universal_principle_ids, extended_id, 
              "Extended principle #{extended_id} must exist in universal principles"
          end
        end
      end
    end
  end

  def test_no_rule_duplication_between_sections
    # Extract all rule texts from different sections
    universal_texts = @config['principles'].map { |p| p['text'] }
    top_level_texts = @config['rules'].map { |r| r['text'] }
    
    stack_texts = []
    @config['stacks'].each do |_, stack_config|
      stack_rules = stack_config['rules'] || []
      stack_texts.concat(stack_rules.map { |r| r['text'] })
    end
    
    # Check for duplicates across sections
    all_texts = universal_texts + top_level_texts + stack_texts
    unique_texts = all_texts.uniq
    
    assert_equal unique_texts.length, all_texts.length,
      "No rule text should be duplicated across sections"
  end

  def test_enforcement_hierarchy_defined
    enforcement = @config['enforcement']
    
    assert enforcement.key?('inheritance_hierarchy'), "Inheritance hierarchy must be defined"
    hierarchy = enforcement['inheritance_hierarchy']
    
    assert_equal 'mandatory_for_all', hierarchy['global_principles']
    assert_equal 'extend_not_override_principles', hierarchy['stack_rules'] 
    assert_equal 'must_comply_with_stack_and_principles', hierarchy['task_rules']
  end

  def test_compliance_checking_mechanisms
    enforcement = @config['enforcement']
    
    assert enforcement.key?('compliance_checking'), "Compliance checking must be defined"
    compliance = enforcement['compliance_checking']
    
    assert_equal 'validate_principle_adherence', compliance['pre_execution']
    assert_equal 'continuous_monitoring', compliance['during_execution']
    assert_equal 'compliance_audit', compliance['post_execution']
  end

  def test_schema_updated_for_new_sections
    schema = @config['schema']
    required_fields = schema['required']
    
    assert_includes required_fields, 'principles'
    assert_includes required_fields, 'enforcement'
    
    properties = schema['properties']
    assert properties.key?('principles')
    assert properties.key?('enforcement')
  end
end

# Run the tests if this file is executed directly
if __FILE__ == $0
  puts "🧪 Running Principles Framework Test Suite..."
  puts "Testing rule nesting bottleneck fixes and universal application..."
  puts "=" * 70
end