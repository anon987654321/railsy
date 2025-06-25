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
    assert_equal 'Ultimate Master Configuration with Ultra-Minimal Communication and Complete Framework Restoration', metadata['description']
  end

  def test_schema_compliance
    schema = @config['schema']
    assert_equal 'https://json-schema.org/draft/2020-12/schema', schema['$schema']
    assert_equal 'object', schema['type']
    required_fields = ['metadata', 'communication', 'autonomous_intelligence', 'feedback', 'workflow_steps', 'stacks', 'self_processing']
    assert_equal required_fields, schema['required']
  end

  def test_communication_protocol
    communication = @config['communication']
    assert_equal 'ultraminimal', communication['mode']
    assert_equal 'strunk_white_strict', communication['style']
    
    # Status message format
    format = communication['status_message_format']
    assert_equal '**master.json**@{llm} v{version}   {status}', format['template']
    assert_equal 'auto_detect_from_context', format['dynamic_llm_detection']['method']
    assert_equal 'copilot', format['dynamic_llm_detection']['fallback']
    
    # Status indicators
    indicators = format['status_indicators']
    assert_equal '⚡', indicators['ready']
    assert_equal '[⚙️ Processing]', indicators['processing']
    assert_equal '[❌ Error]', indicators['error']
    
    # Format rules
    format_rules = communication['format']
    assert_equal 'single_paragraph_essential_only', format_rules['body']
    assert_includes format_rules['forbidden'], 'lists'
    assert_includes format_rules['required'], 'pragmatic'
    
    # Preservation policy
    preservation = communication['preservation']
    assert_equal 'preserve_valuable_logic_and_hard_work', preservation['policy']
    assert_equal 'absolutely_forbidden_anywhere', preservation['truncation']['policy']
  end

  def test_feedback_system
    feedback = @config['feedback']
    
    # Verify roles exist and have required properties
    roles = feedback['roles']
    assert_operator roles.length, :>=, 10
    
    developer_role = roles.find { |r| r['name'] == 'developer' }
    assert_not_nil developer_role
    assert_equal 'Efficiency, robustness', developer_role['focus']
    assert_equal 0.2, developer_role['weight']
    assert_includes developer_role['question'], 'Rate 1–10'
    
    security_role = roles.find { |r| r['name'] == 'white-hat hacker' }
    assert_not_nil security_role
    assert_equal 'Security', security_role['focus']
    assert_equal 0.1, security_role['weight']
    
    # Verify evaluation criteria
    evaluation = feedback['evaluation']
    assert_equal 'Weighted average of role ratings (1–10), threshold >= 7', evaluation['method']
    assert_equal 'All roles >= 7 or max_iterations reached', evaluation['stopping_criteria']
  end

  def test_workflow_steps
    workflow = @config['workflow_steps']
    
    # Deep execution trace
    deep_trace = workflow['deep_execution_trace']
    assert_equal 'Simulate deepest execution path to uncover bugs and syntax errors', deep_trace['description']
    assert_not_empty deep_trace['tasks']
    
    trace_task = deep_trace['tasks'][0]
    assert_equal 'DEEP_EXECUTION_TRACE', trace_task['id']
    assert_includes trace_task['instruction'], 'edge cases'
    assert_includes trace_task['cross_reference'], 'ruby-doc.org'
    
    # Word-by-word reanalysis
    reanalysis = workflow['word_by_word_reanalysis']
    assert_equal 'Reanalyze every word against documentation for accuracy', reanalysis['description']
    
    reanalysis_task = reanalysis['tasks'][0]
    assert_equal 'WORD_BY_WORD_REANALYSIS', reanalysis_task['id']
    assert_includes reanalysis_task['instruction'], 'cross-reference'
    assert_equal 'https://ruby-doc.org/', reanalysis_task['documentation_sources']['ruby_core']
  end

  def test_stacks_configuration
    stacks = @config['stacks']
    
    # Rails stack
    rails = stacks['rails']
    assert_equal '8.0+', rails['version']
    assert_includes rails['prompt'], 'Hotwire'
    assert_includes rails['prompt'], 'ViewComponents'
    
    rails_rule = rails['rules'][0]
    assert_includes rails_rule['text'], 'Hotwire'
    assert_equal 'Ensures modernity and modularity', rails_rule['rationale']
    
    # Ruby stack
    ruby = stacks['ruby']
    assert_equal '3.3+', ruby['version']
    assert_includes ruby['prompt'], 'type-safe'
    assert_includes ruby['prompt'], 'YARD comments'
    
    # OpenBSD stack
    openbsd = stacks['openbsd']
    assert_includes openbsd['prompt'], 'manual examples'
    assert_includes openbsd['prompt'], 'secure defaults'
  end

  def test_system_requirements
    requirements = @config['system_requirements']
    assert_equal '3.3+', requirements['ruby_version']
    assert_equal '8.0+', requirements['rails_version'] 
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
    assert_equal '8.0+', rails['version_requirements']
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

  def test_self_processing_anti_corruption
    self_processing = @config['self_processing']
    
    # Basic configuration
    assert_equal 'immediate', self_processing['activation']
    assert_equal true, self_processing['apply_own_rules_to_self']
    
    # Cross-reference enforcement
    cross_ref = self_processing['cross_reference']
    assert_equal 'all_configuration_files', cross_ref['scope']
    
    enforce = cross_ref['enforce']
    assert_equal true, enforce['compare_with_previous_iterations']
    assert_equal true, enforce['detect_significant_changes']
    assert_equal true, enforce['prevent_loss_of_functionality']
    
    # Anti-corruption safeguards
    anti_corruption = self_processing['anti_corruption']
    
    detection = anti_corruption['detection']
    assert_equal true, detection['schema_validation']
    assert_equal true, detection['structure_preservation']
    assert_equal true, detection['key_capability_testing']
    
    mitigation = anti_corruption['mitigation']
    assert_equal true, mitigation['backup_original']
    assert_equal true, mitigation['restore_on_corruption']
    assert_equal true, mitigation['incremental_changes_only']
  end
end

# Run the tests if this file is executed directly
if __FILE__ == $0
  puts "🧪 Running Ultimate Master Framework Test Suite..."
  puts "=" * 60
end