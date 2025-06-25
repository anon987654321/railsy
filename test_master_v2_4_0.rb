#!/usr/bin/env ruby
# frozen_string_literal: true

# Master.json v2.4.0 Test Suite
# Validates the integrated autonomous framework components

require 'json'
require 'test/unit'

class MasterV240Test < Test::Unit::TestCase
  def setup
    @config = JSON.parse(File.read('prompts/master_v2.4.0.json'))
  end

  def test_metadata_and_versioning
    metadata = @config['metadata']
    assert_equal 'v2.4.0', metadata['version']
    assert_equal '2025-06-25 00:41:13', metadata['updated']
    assert_equal '2.4', metadata['schema_version']
    assert_equal 'anon987654321', metadata['author']
    
    # Test compatibility
    compatibility = metadata['compatibility']
    assert_equal true, compatibility['heavy_scrutiny_default']
    assert_includes compatibility['previous_versions'], '2.3.5'
    assert_includes compatibility['cross_llm_support'], 'claude'
  end

  def test_autonomous_self_processing_integration
    processing = @config['autonomous_self_processing']
    assert_equal true, processing['enabled']
    assert_equal 'surgical_enhancement_with_rollback', processing['philosophy']
    
    # Test safety mechanisms
    safety = processing['safety_mechanisms']
    assert_equal 3, safety['circuit_breaker']['failure_threshold']
    assert_equal 3, safety['recursion_limits']['max_depth']
    assert_equal true, safety['resource_monitoring']['memory_usage_tracking']
    
    # Test audit trail
    audit = processing['audit_trail']
    assert_equal true, audit['comprehensive_logging']
    assert_equal 'before_each_modification', audit['state_snapshots']
    assert_equal 'automatic_creation', audit['rollback_points']
    
    # Test emergency protocols
    emergency = processing['emergency_protocols']
    assert_includes emergency['halt_triggers'], 'recursion_depth_exceeded'
    assert_includes emergency['recovery_actions'], 'restore_last_valid_state'
  end

  def test_multi_role_feedback_system
    feedback = @config['multi_role_feedback_system']
    assert_equal true, feedback['enabled']
    assert_equal 7.0, feedback['weighted_evaluation']['threshold_requirement']
    
    # Test role configuration
    roles = feedback['weighted_evaluation']['roles']
    assert_equal 6, roles.length
    
    # Test security expert role (critical component)
    security_expert = roles.find { |r| r['name'] == 'security_expert' }
    assert_not_nil security_expert
    assert_equal 0.2, security_expert['temperature']
    assert_equal 0.25, security_expert['weight']
    assert_includes security_expert['focus'], 'vulnerabilities'
    
    # Test developer role
    developer = roles.find { |r| r['name'] == 'developer' }
    assert_not_nil developer
    assert_equal 0.20, developer['weight']
    assert_includes developer['focus'], 'performance'
    
    # Test consensus building
    consensus = feedback['consensus_building']
    assert_equal true, consensus['weighted_voting']
    assert_equal 'expert_domain_priority', consensus['conflict_resolution']
    assert_equal 0.7, consensus['minimum_agreement_threshold']
  end

  def test_deep_analysis_methods
    analysis = @config['deep_analysis_methods']
    
    # Test word-by-word reanalysis
    reanalysis = analysis['word_by_word_reanalysis']
    assert_equal true, reanalysis['enabled']
    assert_equal true, reanalysis['character_level_inspection']
    assert_equal true, reanalysis['exhaustive_processing']['ignore_computational_limits']
    
    # Test documentation cross-reference
    docs = reanalysis['documentation_cross_reference']
    assert_equal 'https://ruby-doc.org/', docs['ruby_docs']
    assert_equal 'https://man.openbsd.org/', docs['openbsd_manual']
    
    # Test execution trace simulation
    trace = analysis['deep_execution_trace_simulation']
    assert_equal true, trace['enabled']
    assert_equal true, trace['all_code_paths']
    assert_equal true, trace['state_tracking']['variable_flow']
    
    # Test simulation constraints
    constraints = trace['simulation_constraints']
    assert_equal 15, constraints['max_recursion_depth']
    assert_equal 100, constraints['max_loop_iterations']
    assert_equal 30000, constraints['timeout_threshold_ms']
    
    # Test dependency verification
    deps = analysis['cross_reference_dependency_verification']
    assert_equal true, deps['dependency_graph_analysis']
    assert_equal true, deps['circular_dependency_detection']
    assert_equal true, deps['security_vulnerability_scanning']
  end

  def test_production_security_integration
    security = @config['production_security_integration']
    
    # Test OpenBSD awareness
    openbsd = security['openbsd_awareness']
    pledge = openbsd['pledge_support']
    assert_equal true, pledge['automatic_analysis']
    assert_equal true, pledge['minimal_privilege_calculation']
    
    # Test common pledge sets
    pledge_sets = pledge['common_pledge_sets']
    assert_includes pledge_sets['web_server'], 'stdio'
    assert_includes pledge_sets['database_client'], 'dns'
    
    # Test unveil support
    unveil = openbsd['unveil_support']
    assert_equal 'automatic_detection', unveil['path_analysis']
    assert_equal true, unveil['minimal_filesystem_access']
    
    # Test security-first configuration
    config = security['security_first_configuration']
    assert_equal true, config['default_deny_principle']
    assert_equal true, config['defense_in_depth']
    assert_equal true, config['least_privilege']
    
    # Test production deployment safety
    deployment = security['production_deployment_safety']
    assert_includes deployment['pre_deployment_checks'], 'security_audit'
    assert_includes deployment['pre_deployment_checks'], 'vulnerability_scan'
    assert_equal true, deployment['runtime_monitoring']['security_event_detection']
  end

  def test_enhanced_error_recovery
    recovery = @config['enhanced_error_recovery']
    
    # Test progressive simplification
    simplification = recovery['progressive_simplification']
    assert_equal true, simplification['enabled']
    assert_includes simplification['fallback_strategies'], 'reduce_feature_complexity'
    assert_includes simplification['fallback_strategies'], 'disable_non_essential_components'
    
    # Test resource exhaustion handling
    exhaustion = simplification['resource_exhaustion_handling']
    assert_equal 'garbage_collection_and_cleanup', exhaustion['memory_optimization']
    assert_equal 'graceful_degradation', exhaustion['timeout_extension']
    
    # Test alternative implementation paths
    paths = recovery['alternative_implementation_paths']
    assert_equal true, paths['path_exploration']
    assert_equal true, paths['success_probability_tracking']
    
    # Test component isolation
    isolation = recovery['component_isolation']
    assert_equal true, isolation['failure_containment']
    assert_equal true, isolation['independent_testing']
    assert_equal 'per_component', isolation['isolated_rollback']
    
    # Test last valid state restoration
    restoration = recovery['last_valid_state_restoration']
    assert_equal true, restoration['automatic_snapshots']
    assert_includes restoration['rollback_triggers'], 'validation_failure'
    assert_includes restoration['rollback_triggers'], 'security_violation'
  end

  def test_heavy_scrutiny_default
    core = @config['core']
    enforcement = core['enforcement']
    
    scrutiny = enforcement['heavy_scrutiny']
    assert_equal true, scrutiny['universal_default']
    assert_includes scrutiny['override_conditions'], 'explicit_user_permission'
    assert_includes scrutiny['scrutiny_levels'], 'maximum'
  end

  def test_enhanced_safety_limits
    safety = @config['core']['safety_limits']
    
    # Test enhanced recursion protection
    assert_equal 'max_depth_3_halt_with_audit', safety['recursion']['protection']
    
    # Test enhanced circuit breaker
    assert_equal 'exponential', safety['circuit_breaker']['recovery_backoff']
    
    # Test enhanced emergency halt
    assert_equal 'user_intervention_required_with_full_report', safety['emergency_halt']
    
    # Test enhanced timeout protection
    timeout = safety['timeout']
    assert_equal 'graceful_halt_with_partial_results_and_recovery_plan', timeout['protection']
  end

  def test_execution_workflows_enhancement
    workflows = @config['execution_workflows']
    
    # Test enhanced self_analysis workflow
    self_analysis = workflows['self_analysis']
    assert_includes self_analysis, 'validate_safety_mechanisms'
    assert_includes self_analysis, 'create_audit_trail'
    
    # Test new deep_analysis workflow
    deep_analysis = workflows['deep_analysis']
    assert_includes deep_analysis, 'word_by_word_examination'
    assert_includes deep_analysis, 'execution_trace_simulation'
    assert_includes deep_analysis, 'dependency_verification'
    
    # Test new security_audit workflow
    security_audit = workflows['security_audit']
    assert_includes security_audit, 'vulnerability_assessment'
    assert_includes security_audit, 'privilege_analysis'
    assert_includes security_audit, 'compliance_verification'
  end

  def test_cross_llm_compatibility
    compatibility = @config['cross_llm_compatibility']
    
    # Test Grok support
    grok = compatibility['grok_support']
    assert_equal true, grok['context_optimization']
    assert_equal 'grok_compatible', grok['response_formatting']
    
    # Test Claude support
    claude = compatibility['claude_support']
    assert_equal true, claude['reasoning_delegation']
    assert_equal true, claude['builtin_capability_leverage']
    
    # Test ChatGPT support
    chatgpt = compatibility['chatgpt_support']
    assert_equal true, chatgpt['structured_output']
    assert_equal true, chatgpt['function_calling']
    
    # Test universal features
    universal = compatibility['universal_features']
    assert_equal true, universal['markdown_output']
    assert_equal true, universal['json_schema_validation']
  end

  def test_version_history_integration
    history = @config['version_history']
    assert_equal 3, history.length
    
    # Test v2.4.0 entry
    v240 = history.find { |v| v['version'] == '2.4.0' }
    assert_not_nil v240
    assert_equal '2025-06-25T00:41:13Z', v240['timestamp']
    assert_match(/Integrated critical autonomous components/, v240['changes'])
    
    # Test integration sources
    sources = v240['integration_source']
    assert_equal 'self_processor.rb', sources['autonomous_self_processing']
    assert_equal 'master_original_backup.json', sources['multi_role_feedback']
    assert_equal '3.txt (v85.5 system)', sources['deep_analysis']
    assert_equal 'openbsd.sh', sources['security_integration']
  end

  def test_schema_validation_framework
    validation = @config['schema_validation']
    assert_equal true, validation['enabled']
    assert_equal true, validation['strict_mode']
    
    # Test required sections
    required = validation['required_sections']
    assert_includes required, 'autonomous_self_processing'
    assert_includes required, 'multi_role_feedback_system'
    assert_includes required, 'deep_analysis_methods'
    assert_includes required, 'production_security_integration'
    assert_includes required, 'enhanced_error_recovery'
    
    # Test integrity checks
    integrity = validation['integrity_checks']
    assert_equal true, integrity['checksum_validation']
    assert_equal true, integrity['structure_preservation']
    assert_equal true, integrity['capability_verification']
  end

  def test_temperature_based_analysis
    # Test reasoning temperatures
    reasoning = @config['reasoning']['temperature']
    assert_equal 0.2, reasoning['self_analysis']
    assert_equal 0.2, reasoning['security_analysis']
    assert_equal 0.4, reasoning['optimization']
    assert_equal 0.9, reasoning['innovation']
    
    # Test multi-role feedback temperatures
    feedback = @config['multi_role_feedback_system']
    consensus = feedback['consensus_building']['temperature_based_analysis']
    assert_equal 0.2, consensus['security_analysis']
    assert_equal 0.9, consensus['creativity_analysis']
    assert_equal 0.4, consensus['balanced_analysis']
  end
end

# Run the tests if this file is executed directly
if __FILE__ == $0
  puts "🧪 Running Master.json v2.4.0 Integration Test Suite..."
  puts "=" * 70
end