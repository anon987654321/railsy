#!/usr/bin/env ruby
# Master Framework v2.4.0 Test Suite
# Validates comprehensive framework capabilities and requirements

require 'json'
require 'test/unit'

class MasterFrameworkV240Test < Test::Unit::TestCase
  def setup
    @config = JSON.parse(File.read('master_v2.4.0.json'))
  end

  def test_metadata_v240_requirements
    metadata = @config['metadata']
    assert_equal '2.4.0', metadata['version']
    assert_equal '2.4', metadata['schema_version']
    assert_equal 'anon987654321', metadata['author']
    assert_equal true, metadata['production_ready']
    assert_equal true, metadata['security_first']
    assert_match(/2025-06-25/, metadata['created'])
    puts "✅ Metadata v2.4.0 requirements validated"
  end

  def test_schema_validation_structure
    schema = @config['schema']
    assert_equal 'https://json-schema.org/draft/2020-12/schema', schema['$schema']
    required_fields = schema['required']
    
    # Validate all required top-level sections are present
    required_fields.each do |field|
      assert @config.key?(field), "Missing required field: #{field}"
    end
    puts "✅ Schema validation structure confirmed"
  end

  def test_multi_role_feedback_system
    feedback = @config['feedback']
    roles = feedback['roles']
    
    # Must have exactly 10 roles
    assert_equal 10, roles.length, "Must have exactly 10 roles"
    
    # Validate all required roles are present
    required_roles = %w[developer maintainer user white-hat_hacker designer product_manager qa_engineer lawyer marketer accessibility_expert]
    role_names = roles.map { |r| r['name'] }
    
    required_roles.each do |req_role|
      assert role_names.include?(req_role), "Missing required role: #{req_role}"
    end
    
    # Validate weights sum to 1.0
    total_weight = roles.sum { |r| r['weight'] }
    assert_in_delta 1.0, total_weight, 0.001, "Role weights must sum to 1.0, got #{total_weight}"
    
    # Validate specific role weights from requirements
    dev_role = roles.find { |r| r['name'] == 'developer' }
    assert_equal 0.2, dev_role['weight'], "Developer weight must be 0.2"
    
    user_role = roles.find { |r| r['name'] == 'user' }
    assert_equal 0.2, user_role['weight'], "User weight must be 0.2"
    
    puts "✅ Multi-role feedback system (10 roles) validated"
  end

  def test_comprehensive_workflow_phases
    steps = @config['steps']
    
    # Must have exactly 9 phases as in the original (the problem statement mentions 8 but lists 9)
    assert_equal 9, steps.length, "Must have exactly 9 workflow phases"
    
    # Validate all required phases are present
    required_phases = %w[preprocess understand create verify deep_execution_trace word_by_word_reanalysis refine deliver reflect]
    phase_names = steps.map { |s| s['name'] }
    
    required_phases.each do |phase|
      assert phase_names.include?(phase), "Missing required phase: #{phase}"
    end
    
    # Validate tasks are present in each phase
    steps.each do |step|
      assert step.key?('tasks'), "Phase #{step['name']} must have tasks"
      assert step['tasks'].length > 0, "Phase #{step['name']} must have at least one task"
    end
    
    puts "✅ Complete 9-phase workflow validated"
  end

  def test_autonomous_framework_integration
    autonomous = @config['autonomous_framework']
    assert_equal true, autonomous['enabled']
    assert autonomous.key?('reasoning')
    assert autonomous.key?('context_detection')
    assert autonomous.key?('execution_framework')
    
    # Validate autonomous features
    context = autonomous['context_detection']
    assert_equal true, context['enabled']
    assert context['auto_workflow_mapping']['project_type_detection'].include?('rails')
    assert context['auto_workflow_mapping']['project_type_detection'].include?('openbsd_script')
    
    puts "✅ Autonomous framework integration validated"
  end

  def test_safety_mechanisms
    safety = @config['safety_mechanisms']
    
    # Validate all required safety mechanisms
    assert safety.key?('recursion')
    assert safety.key?('circuit_breaker')
    assert safety.key?('emergency_halt')
    assert safety.key?('forbidden_removals')
    
    # Validate recursion safety
    recursion = safety['recursion']
    assert_equal 3, recursion['max_depth']
    assert_equal 'enabled', recursion['tracking']
    
    # Validate circuit breaker
    circuit = safety['circuit_breaker']
    assert_equal true, circuit['enabled']
    assert_equal 3, circuit['failure_threshold']
    assert_equal 300, circuit['timeout_seconds']
    
    puts "✅ Safety mechanisms validated"
  end

  def test_production_tech_stack_support
    stacks = @config['stacks']
    
    # Must include all required stacks
    required_stacks = %w[global architecture openbsd rails ruby frontend zsh]
    stack_names = stacks.keys
    
    required_stacks.each do |stack|
      assert stack_names.include?(stack), "Missing required stack: #{stack}"
    end
    
    # Validate Rails 8.0+ requirement
    rails_stack = stacks['rails']
    assert_equal '8.0+', rails_stack['version']
    assert rails_stack['dependencies'].include?('hotwire')
    assert rails_stack['dependencies'].include?('stimulus')
    
    # Validate Ruby 3.3+ requirement  
    ruby_stack = stacks['ruby']
    assert_equal '3.3+', ruby_stack['version']
    
    puts "✅ Production tech stack support validated"
  end

  def test_deep_analysis_capabilities
    analysis = @config['deep_analysis_capabilities']
    
    # Validate multi-temperature analysis
    temp_analysis = analysis['multi_temperature_perspective_analysis']
    assert_equal true, temp_analysis['enabled']
    
    profiles = temp_analysis['temperature_profiles']
    assert profiles.length >= 6, "Must have at least 6 temperature profiles"
    
    # Validate word-for-word examination
    examination = analysis['word_for_word_code_examination']
    assert_equal true, examination['enabled']
    assert_equal true, examination['exhaustive_analysis']['character_level_review']
    assert_equal true, examination['execution_path_tracing']['deepest_path_simulation']
    
    puts "✅ Deep analysis capabilities validated"
  end

  def test_enhanced_error_recovery
    autonomous = @config['autonomous_framework']
    recovery = autonomous['execution_framework']['recovery_protocols']
    
    assert recovery['error_detection']['runtime_errors']
    assert recovery['error_detection']['security_violations']
    
    strategies = recovery['recovery_strategies']
    assert strategies.include?('identify_failure_point')
    assert strategies.include?('implement_recovery_solution')
    
    fallbacks = recovery['fallback_mechanisms']
    assert_equal true, fallbacks['emergency_rollback']
    assert_equal true, fallbacks['graceful_degradation']
    
    puts "✅ Enhanced error recovery validated"
  end

  def test_self_optimization_features
    optimization = @config['self_optimization']
    assert_equal true, optimization['enabled']
    assert_equal 'surgical_enhancement', optimization['philosophy']
    
    constraints = optimization['constraints']
    assert_equal true, constraints['preserve_functionality']
    assert_equal true, constraints['maintain_safety']
    assert_equal true, constraints['minimal_changes_only']
    
    puts "✅ Self-optimization features validated"
  end

  def test_system_requirements
    requirements = @config['system_requirements']
    assert_equal '3.3+', requirements['ruby_version']
    assert_equal '8.0+', requirements['rails_version']
    assert_equal '7.7+', requirements['openbsd_version']
    assert_equal true, requirements['langchain_integration']
    assert_equal 'pledge_unveil_first', requirements['security_framework']
    
    # Validate cross-LLM compatibility
    compatibility = requirements['cross_llm_compatibility']
    assert compatibility.include?('grok')
    assert compatibility.include?('claude')
    assert compatibility.include?('chatgpt')
    
    puts "✅ System requirements validated"
  end

  def test_file_size_requirements
    file_size = File.size('master_v2.4.0.json')
    line_count = File.readlines('master_v2.4.0.json').length
    
    # Validate file size is substantial (should be 15k-25k+ bytes for comprehensive framework)
    assert file_size >= 15000, "File size should be at least 15,000 bytes for comprehensive framework, got #{file_size}"
    
    # Validate line count is substantial (should be 500-800+ lines)
    assert line_count >= 500, "Line count should be at least 500 lines for comprehensive framework, got #{line_count}"
    
    puts "✅ File size requirements validated (#{file_size} bytes, #{line_count} lines)"
  end

  def test_compliance_validation_structure
    compliance = @config['compliance_validation']
    
    assert compliance.key?('schema_validation')
    assert compliance.key?('principle_adherence')
    assert compliance.key?('quality_gates')
    
    schema_val = compliance['schema_validation']
    assert_equal true, schema_val['enabled']
    assert_equal true, schema_val['json_schema_compliance']
    
    principles = compliance['principle_adherence']
    assert_equal 'enforced', principles['solid_principles']
    assert_equal 'maintained', principles['parametric_design']
    
    puts "✅ Compliance validation structure validated"
  end
end