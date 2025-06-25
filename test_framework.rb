#!/usr/bin/env ruby
# Ultimate Master Framework Test Suite
# Validates core framework capabilities

require 'json'
require 'test/unit'

class UltimateMasterFrameworkTest < Test::Unit::TestCase
  def setup
    @config = JSON.parse(File.read('master.json'))
  end

  def test_framework_metadata
    metadata = @config['metadata']
    assert_equal 'v2.8.4-ultimate-enhanced-corrected', metadata['version']
    assert_equal true, metadata['production_ready']
    assert_equal true, metadata['security_first']
    assert_equal 'anon987654321', metadata['author']
  end

  def test_system_requirements
    requirements = @config['system_requirements']
    assert_equal '3.3.5+', requirements['ruby_version']
    assert_equal '8.1+', requirements['rails_version'] 
    assert_equal '7.7+', requirements['openbsd_version']
    assert_equal true, requirements['langchain_integration']
    assert_equal 'pledge_unveil_first', requirements['security_framework']
  end

  def test_autonomous_intelligence
    ai = @config['autonomous_intelligence']
    
    # Context detection
    context = ai['context_detection']
    assert_equal true, context['enabled']
    assert_includes context['auto_workflow_mapping']['project_type_detection'], 'rails'
    assert_includes context['auto_workflow_mapping']['project_type_detection'], 'openbsd_script'
    
    # Execution framework
    execution = ai['execution_framework']
    assert_equal true, execution['autonomous_progression']['enabled']
    assert_includes execution['recovery_protocols']['recovery_strategies'], 'identify_failure_point'
  end

  def test_deep_analysis_capabilities
    analysis = @config['deep_analysis_capabilities']
    
    # Multi-temperature analysis
    temp_analysis = analysis['multi_temperature_perspective_analysis']
    assert_equal true, temp_analysis['enabled']
    
    security_expert = temp_analysis['temperature_profiles'].find { |p| p['role'] == 'security_expert' }
    assert_not_nil security_expert
    assert_equal 0.2, security_expert['temperature']
    assert_equal 0.25, security_expert['weight']
    
    # Word-for-word examination
    examination = analysis['word_for_word_code_examination']
    assert_equal true, examination['enabled']
    assert_equal true, examination['exhaustive_analysis']['character_level_review']
  end

  def test_production_security
    security = @config['production_security']
    
    # OpenBSD integration
    openbsd = security['openbsd_integration']
    assert_equal true, openbsd['pledge_support']['automatic_pledge_generation']
    assert_equal true, openbsd['unveil_support']['automatic_path_analysis']
    
    # Rails security
    rails = security['rails_security']
    assert_equal '8.1+', rails['version_requirements']
    assert_equal 'enforced', rails['security_features']['strong_parameters']
  end

  def test_reasoning_frameworks
    reasoning = @config['reasoning_frameworks']
    
    # Framework selection
    selection = reasoning['framework_selection']['problem_classification']
    assert_equal 'direct_implementation', selection['simple_execution']
    assert_equal 'tree_of_thoughts', selection['complex_exploration']
    assert_equal 'constitutional_ai', selection['ethical_concerns']
    
    # Constitutional AI
    constitutional = reasoning['constitutional_ai']
    assert_includes constitutional['principles']['security_first'], 'no_vulnerabilities'
    assert_includes constitutional['principles']['security_first'], 'defense_in_depth'
  end

  def test_project_lifecycle
    lifecycle = @config['project_lifecycle']
    
    # Phases
    phases = lifecycle['phases']
    assert_includes phases.keys, 'discovery'
    assert_includes phases.keys, 'planning'
    assert_includes phases.keys, 'implementation'
    assert_includes phases.keys, 'validation'
    assert_includes phases.keys, 'delivery'
    
    # Quality gates
    gates = lifecycle['quality_gates']
    assert_includes gates['security'], 'no_critical_vulnerabilities'
    assert_includes gates['quality'], 'code_coverage_80_percent'
  end

  def test_installer_integration
    installer = @config['installer_integration']
    
    # OpenBSD installer
    openbsd = installer['openbsd_installer']
    assert_equal 'pkg_add_automation', openbsd['package_management']
    assert_equal 'rcctl_integration', openbsd['service_configuration']
    
    # Rails installer
    rails = installer['rails_installer']
    assert_equal 'bundler_integration', rails['gem_management']
    assert_equal 'postgresql_configuration', rails['database_setup']
  end

  def test_anti_corruption_safeguards
    safeguards = @config['anti_corruption_safeguards']
    
    # Schema validation
    validation = safeguards['schema_validation']
    assert_equal true, validation['json_schema_compliance']
    assert_equal true, validation['structure_preservation']
    
    # Version control
    version_control = safeguards['version_control']
    assert_equal true, version_control['backup_before_changes']
    assert_equal true, version_control['rollback_on_degradation']
  end

  def test_performance_optimization
    performance = @config['performance_optimization']
    
    # Resource management
    resources = performance['resource_management']
    assert_equal true, resources['memory_optimization']['garbage_collection_tuning']
    assert_equal true, resources['cpu_optimization']['algorithm_efficiency_analysis']
    
    # Caching strategies
    caching = performance['caching_strategies']
    assert_equal 'redis_integration', caching['application_cache']
    assert_equal 'query_optimization', caching['database_cache']
  end

  def test_status_message_format
    status_format = @config['status_message_format']
    
    # Template format
    assert_equal "**master.json**@{llm} v{version}   {status}", status_format['template']
    
    # Status indicators
    indicators = status_format['status_indicators']
    assert_equal "⚡", indicators['ready']
    assert_equal "[⚙️ Processing]", indicators['processing']
    assert_equal "[✅ Complete]", indicators['complete']
    
    # Dynamic LLM detection
    llm_detection = status_format['dynamic_llm_detection']
    assert_equal "auto_detect_from_context", llm_detection['method']
    assert_equal "copilot", llm_detection['fallback']
  end

  def test_communication_protocol
    communication = @config['communication']
    
    # Style and scope
    assert_equal "strunk_white_strict", communication['style']
    assert_equal "all_content_including_code_and_documentation", communication['scope']
    
    # Format requirements
    format = communication['format']
    assert_equal "**master.json**@{llm} v{version}   {status}", format['status_line']
    assert_equal "single_paragraph_essential_only", format['body']
    assert_includes format['forbidden'], "lists"
    assert_includes format['forbidden'], "emojis"
    assert_includes format['required'], "pragmatic"
    assert_includes format['required'], "actionable"
    
    # Truncation policy
    truncation = communication['truncation']
    assert_equal "absolutely_forbidden_anywhere", truncation['policy']
    assert_equal "complete_content_delivery_mandatory", truncation['enforcement']
  end

  def test_core_framework
    core = @config['core']
    
    # Basic settings
    assert_equal "active_with_environment_isolation", core['mode']
    assert_equal true, core['autonomous']
    assert_equal "ultraminimal", core['communication_mode']
    assert_equal true, core['silent_processing']
    
    # Safety limits
    safety = core['safety_limits']
    assert_equal "unlimited_with_circuit_breaker", safety['recursion']['max_depth']
    assert_equal "intelligent_loop_detection", safety['recursion']['protection']
    assert_equal "unlimited_with_user_control", safety['timeout']['default']
    assert_equal "unlimited_with_garbage_collection", safety['memory']['max']
    
    # Context persistence
    persistence = core['context_persistence']
    assert_equal true, persistence['enabled']
    session_state = persistence['session_state']
    assert_equal "persist_across_sessions", session_state['project_config']
    assert_equal "resume_where_left_off", session_state['workflow_progress']
    assert_equal "accumulate_knowledge", session_state['learned_patterns']
  end
end

# Run the tests if this file is executed directly
if __FILE__ == $0
  puts "🧪 Running Ultimate Master Framework Test Suite..."
  puts "=" * 60
end