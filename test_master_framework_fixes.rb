#!/usr/bin/env ruby
# Test suite for validating master.json framework rule nesting and universal enforcement fixes

require 'json'
require 'test/unit'

class MasterFrameworkFixesTest < Test::Unit::TestCase
  def setup
    @config = JSON.parse(File.read('prompts/master.json'))
  end

  def test_universal_enforcement_section_exists
    assert @config.key?('universal_enforcement'), "Missing universal_enforcement section"
    
    universal = @config['universal_enforcement']
    assert universal.key?('global_principles'), "Missing global_principles in universal_enforcement"
    assert universal.key?('quality_standards'), "Missing quality_standards in universal_enforcement"
    assert universal.key?('security_defaults'), "Missing security_defaults in universal_enforcement"
    assert universal.key?('communication_standards'), "Missing communication_standards in universal_enforcement"
  end

  def test_solid_principles_applied_universally
    principles = @config['universal_enforcement']['global_principles']
    
    solid_principles = %w[single_responsibility open_closed liskov_substitution interface_segregation dependency_inversion]
    solid_principles.each do |principle|
      assert principles.key?(principle), "Missing SOLID principle: #{principle}"
      assert_equal true, principles[principle]['enforced_globally'], "#{principle} not enforced globally"
    end
  end

  def test_parametric_design_enforced_universally
    principles = @config['universal_enforcement']['global_principles']
    assert principles.key?('parametric_design'), "Missing parametric_design principle"
    assert_equal true, principles['parametric_design']['enforced_globally'], "Parametric design not enforced globally"
  end

  def test_security_defaults_applied_universally
    security = @config['universal_enforcement']['security_defaults']
    
    required_defaults = %w[input_validation output_encoding secure_communications least_privilege]
    required_defaults.each do |default|
      assert security.key?(default), "Missing security default: #{default}"
      assert_equal 'always', security[default]['enforcement'], "#{default} not enforced universally"
    end
  end

  def test_communication_standards_enforced
    comm = @config['universal_enforcement']['communication_standards']
    
    assert_equal 'double_backticks', comm['code_quoting_standard'], "Code quoting standard not set to double backticks"
    assert_equal true, comm['strunk_white_clarity'], "Strunk & White clarity not enforced"
    assert_equal true, comm['logical_spacing_required'], "Logical spacing not required"
  end

  def test_unified_validation_system_exists
    assert @config.key?('unified_validation'), "Missing unified_validation section"
    
    validation = @config['unified_validation']
    assert validation.key?('universal_checkpoint'), "Missing universal_checkpoint"
    assert_equal 'all_contexts', validation['applies_to'], "Validation not applied to all contexts"
    assert validation['rules_enforced'].include?('universal_enforcement'), "Universal enforcement not included in validation"
  end

  def test_no_critical_principles_in_conditional_sections
    # Verify SOLID principles are not nested in stack-specific sections
    stacks = @config['stacks']
    solid_keywords = ['solid', 'single_responsibility', 'open_closed', 'liskov', 'interface_segregation', 'dependency_inversion']
    
    stacks.each do |stack_name, stack_config|
      next if stack_name == 'global'
      
      stack_text = stack_config.to_s.downcase
      solid_keywords.each do |keyword|
        assert !stack_text.include?(keyword), "SOLID principle '#{keyword}' found in stack-specific section '#{stack_name}' - should be in universal_enforcement"
      end
    end
  end

  def test_status_message_format_correct
    # Verify no emoji wrapped in square brackets outside of incorrect_format examples
    config_copy = @config.dup
    
    # Remove the examples section which intentionally shows incorrect format
    if config_copy['status_indicators'] && config_copy['status_indicators']['examples']
      config_copy['status_indicators']['examples'].delete('incorrect_format')
    end
    
    config_text = config_copy.to_s
    assert !config_text.match(/\[:[^:]+:\]/), "Found emoji incorrectly wrapped in square brackets"
  end

  def test_universal_rules_not_duplicated_in_stacks
    universal_principles = @config['universal_enforcement']['global_principles'].keys
    
    @config['stacks'].each do |stack_name, stack_config|
      next if stack_name == 'global'
      
      stack_rules = stack_config['rules'] || []
      stack_text = stack_rules.map { |r| r['text'] || '' }.join(' ').downcase
      
      universal_principles.each do |principle|
        principle_words = principle.split('_')
        # Check if multiple words from the principle appear in stack rules
        matches = principle_words.count { |word| stack_text.include?(word) }
        assert matches < principle_words.length, "Universal principle '#{principle}' appears to be duplicated in stack '#{stack_name}'"
      end
    end
  end
end