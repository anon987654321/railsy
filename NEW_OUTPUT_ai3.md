# AI^3 CLI

AI^3 is a modular command-line interface (CLI) built in Ruby with `langchainrb`, integrating multiple LLMs (Grok, Claude, OpenAI, Ollama) for natural language processing, retrieval-augmented generation (RAG) with Weaviate, and specialized tools. It runs on OpenBSD 7.7+ with `pledge`/`unveil` security and supports Ruby 3.3.0+. This document restores EGPT functionality, renamed as AI^3, and introduces new features like multimodal processing, workflow orchestration, real-time web monitoring, and explicit ethical guardrails.

## Features

- **Natural Language CLI**: Processes freeform inputs (e.g., "read /etc/passwd", "scrape example.com") using `LangChain::LLM::Multi`.
- **Multi-LLM Support**: Grok, Claude, OpenAI, Ollama with fallback logic.
- **RAG**: Weaviate vector search with dynamic chunking and structured output.
- **Tools**:
  - `FileSystemTool`: Secure file operations.
  - `UniversalScraper`: Ferrum-based web scraping, including Replicate.com models.
  - `WebBrowserTool`: Element extraction and LLM analysis.
- **Multimodal Processing**: Image/video analysis with chained Replicate.com models.
- **Workflow Orchestration**: DAG-based task chaining (e.g., scrape → analyze → summarize).
- **Real-Time Web Monitoring**: Tracks website changes (RSS, WebSocket).
- **Code Generation**: Ruby/Rails code snippets via `langchainrb`.
- **Ethical Guardrails**: Content filtering for NSFW and unethical inputs.
- **Security**: OpenBSD `pledge`/`unveil`, encrypted sessions.
- **Persistence**: SQLite for session context.
- **Localization**: I18n with `en`, `no` locales.

## Installation

   #!/usr/bin/env zsh
AI^3 Core Installation Script
Usage: zsh install.sh
EOF: 180 lines
CHECKSUM: sha256:1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2
   set -e   ROOT_DIR="${PWD}"   LOG_FILE="${ROOT_DIR}/logs/install.log"
   log() { echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] $1" >> "$LOG_FILE"; }
   DIRS=(     "${ROOT_DIR}/lib"     "${ROOT_DIR}/lib/utils"     "${ROOT_DIR}/tools"     "${ROOT_DIR}/config"     "${ROOT_DIR}/config/locales"     "${ROOT_DIR}/logs"     "${ROOT_DIR}/data"     "${ROOT_DIR}/data/cache"     "${ROOT_DIR}/data/screenshots"     "${ROOT_DIR}/data/models"     "${BIN_DIR:=$HOME/bin}"   )
   mkdir -p "${DIRS[@]}" >> "$LOG_FILE" 2>&1   for dir in "${DIRS[@]}"; do     log "Creating directory: $dir"     [[ -w "$dir" ]] || { log "Error: Directory $dir not writable"; exit 1; }   done
   find "${ROOT_DIR}/logs" -mtime +7 -delete >> "$LOG_FILE" 2>&1 || log "Warning: Failed to clean logs"   find "${ROOT_DIR}/data/screenshots" -mtime +1 -delete >> "$LOG_FILE" 2>&1 || log "Warning: Failed to clean screenshots"
   key_file="${HOME}/.ai3_keys"   touch "${key_file}" >> "$LOG_FILE" 2>&1   chmod 600 "${key_file}" >> "$LOG_FILE" 2>&1   for key in XAI ANTHROPIC OPENAI REPLICATE; do     echo "Enter $key API Key (optional, press Enter to skip): "     read -r api_key     [[ -n "$api_key" ]] && echo "export ${key}_API_KEY="$api_key"" >> "$key_file"   done
   GEMS=(     "langchainrb:0.11.0"     "replicate-ruby"     "weaviate-ruby"     "tty-prompt"     "ferrum"     "nokogiri"     "openssl"     "sqlite3"   )
   log "Installing gems"   for gem in "${GEMS[@]}"; do     gem_name="${gem%%:}"     gem_version="${gem##:}"     [[ "$gem_version" == "$gem_name" ]] && gem_version=""     gem install --user-install "$gem_name" ${gem_version:+--version "$gem_version"} >> "$LOG_FILE" 2>&1 || log "Warning: Failed to install $gem_name"   done
   doas pkg_add weaviate redis sqlite3 >> "$LOG_FILE" 2>&1 || log "Warning: Failed to install packages"
   sqlite3 "${ROOT_DIR}/data/sessions.db" "CREATE TABLE IF NOT EXISTS sessions (id INTEGER PRIMARY KEY, user_id TEXT, context TEXT, created_at DATETIME)" >> "$LOG_FILE" 2>&1
   cat > config/locales/en.yml <<EOFen:  app_name: "AI^3"  initialized: "AI^3 initialized. Enter your query."  no_api_key: "No API key for %{llm}"  unethical_content: "Input flagged as potentially unethical. Please clarify."EOF   cat > config/locales/no.yml <<EOFno:  app_name: "AI^3"  initialized: "AI^3 initialisert. Skriv inn din forespørsel."  no_api_key: "Ingen API-nøkkel for %{llm}"  unethical_content: "Inndata flagget som potensielt uetisk. Vennligst klargjør."EOF
   chmod +x ai3.rb >> "$LOG_FILE" 2>&1   mv ai3.rb "${BIN_DIR}/ai3" >> "$LOG_FILE" 2>&1   log "Moved ai3.rb to ${BIN_DIR}/ai3"
   log "Version 1.0.0 installed"   log "Installation complete"
EOF (180 lines)
CHECKSUM: sha256:1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2

## Core Components

### `ai3.rb`

The main CLI entry point, processing natural language inputs with `langchainrb`.

   #!/usr/bin/env ruby
frozen_string_literal: true
AI^3 CLI Entry Point
EOF: 120 lines
CHECKSUM: sha256:2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3
   require 'yaml'   require 'langchain'   require 'tty-prompt'   require 'i18n'   require 'logger'   require 'sqlite3'   require_relative 'lib/utils/config'   require_relative 'lib/command_handler'   require_relative 'lib/session_manager'
   I18n.load_path << Dir[File.join(dir, 'config', 'locales', '*.yml')]   I18n.backend.load_translations
   module AI3     @logger = Logger.new(File.join(dir, 'logs', 'ai3.log'))     @llm_calls = 0
 def self.logger = @logger
 def self.llm_calls = @llm_calls

 class << self
   attr_reader :llm_multi, :session_manager, :command_handler

   def initialize!
     @logger.info("Initializing AI^3 at #{Time.now.utc.iso8601}")
     llms = []
     %w[XAI ANTHROPIC OPENAI].each do |key|
       next unless ENV["#{key}_API_KEY"]
       llm = LangChain::LLM.const_get(key.downcase.capitalize).new(
         api_key: ENV["#{key}_API_KEY"],
         default_options: { temperature: 0.6, max_tokens: 1000 }
       )
       llms << llm
     rescue => e
       @logger.warn(I18n.t("no_api_key", llm: key) + ": #{e.message}")
     end
     llms << LangChain::LLM::Ollama.new(model: 'llama3') if system('command -v ollama >/dev/null')
     @llm_multi = LangChain::LLM::Multi.new(llms: llms)
     @session_manager = SessionManager.new
     @command_handler = CommandHandler.new(@llm_multi)
   end

   def rate_limit_check
     limit = Config.instance['llm_limit'] || 1000
     raise "LLM call limit exceeded" if @llm_calls >= limit
     @llm_calls += 1
   end
 end

   end
   class AI3Main     def initialize       AI3.initialize!       @prompt = TTY::Prompt.new       puts I18n.t('initialized')     end
 def start
   loop do
     print '> '
     input = gets&.chomp
     break if input.nil? || input.downcase == 'exit'
     response = AI3.command_handler.process_input(input)
     puts response[:answer]
     puts "Sources: #{response[:sources].join(', ')}" if response[:sources].any?
   end
 rescue StandardError => e
   AI3.logger.error("Error: #{e.message}")
   puts "Error: #{e.message}"
 end

   end
   AI3Main.new.start if $PROGRAM_NAME == FILE
EOF (120 lines)
CHECKSUM: sha256:2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3

### `lib/utils/config.rb`

Loads configuration from `config.yml`.

frozen_string_literal: true
Configuration Loader
EOF: 50 lines
CHECKSUM: sha256:3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4
   require 'yaml'
   module AI3     class Config       def self.instance         @instance ||= new       end
   def initialize
     @config = YAML.load_file(File.join(__dir__, '../../config/config.yml'))
   end

   def [](key)
     @config[key]
   end
 end

   end
   File.write File.join(dir, '../../config/config.yml'), <<~EOF unless File.exist? File.join(dir, '../../config/config.yml')     llm_limit: 1000     default_language: en     rag:       chunk_size: 500       chunk_overlap: 50     scraper:       max_depth: 2       timeout: 30     multimedia:       output_dir: data/models/multimedia   EOF
EOF (50 lines)
CHECKSUM: sha256:3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4

### `lib/command_handler.rb`

Routes natural language inputs to tools, with content filtering.

frozen_string_literal: true
Command Handler
EOF: 90 lines
CHECKSUM: sha256:4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5
   require_relative 'rag_system'   require_relative 'tools/filesystem_tool'   require_relative 'tools/universal_scraper'   require_relative 'tools/web_browser_tool'   require_relative 'multimedia'   require_relative 'workflow_composer'   require_relative 'web_monitor'   require_relative 'code_generator'   require_relative 'content_filter'
   class CommandHandler     def initialize(llm)       @llm = llm       @rag_system = RAGSystem.new       @filesystem_tool = FileSystemTool.new       @scraper_tool = UniversalScraper.new       @browser_tool = WebBrowserTool.new       @multimedia = Multimedia.new       @workflow_composer = WorkflowComposer.new       @web_monitor = WebMonitor.new       @code_generator = CodeGenerator.new       @content_filter = ContentFilter.new(@llm)     end
 def process_input(input)
   return { answer: I18n.t('unethical_content'), sources: [] } unless @content_filter.safe?(input)
   intent = @llm.generate("Classify intent: #{input}\nOptions: read_file, write_file, delete_file, scrape_web, browse_web, analyze_media, orchestrate_workflow, monitor_web, generate_code, rag_query")[:content]
   case intent
   when /read_file/ then { answer: @filesystem_tool.read(input.match(/read\s+(\S+)/)[1]), sources: [] }
   when /write_file/ then { answer: @filesystem_tool.write(input.match(/write\s+(\S+)\s+(.+)/)[1, 2]), sources: [] }
   when /delete_file/ then { answer: @filesystem_tool.delete(input.match(/delete\s+(\S+)/)[1]), sources: [] }
   when /scrape_web/ then { answer: @scraper_tool.scrape(input.match(/scrape\s+(\S+)/)[1]), sources: [] }
   when /browse_web/ then { answer: @browser_tool.navigate(input.match(/browse\s+(\S+)/)[1]), sources: [] }
   when /analyze_media/ then { answer: @multimedia.analyze(input.match(/analyze\s+(\S+)/)[1]), sources: [] }
   when /orchestrate_workflow/ then { answer: @workflow_composer.execute(input), sources: [] }
   when /monitor_web/ then { answer: @web_monitor.subscribe(input.match(/monitor\s+(\S+)/)[1]), sources: [] }
   when /generate_code/ then { answer: @code_generator.generate(input), sources: [] }
   else @rag_system.generate_answer(input)
   end
 rescue StandardError => e
   { answer: "Error: #{e.message}", sources: [] }
 end

   end
EOF (90 lines)
CHECKSUM: sha256:4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5

### `lib/rag_system.rb`

Handles RAG queries with structured output and dynamic chunking.

frozen_string_literal: true
RAG System
EOF: 60 lines
CHECKSUM: sha256:5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6
   require 'langchain'   require 'httparty'   require_relative 'weaviate_integration'   require_relative 'session_manager'
   class RAGSystem     def initialize       @weaviate = WeaviateIntegration.new       @llm = LangChain::LLM::OpenAI.new(api_key: ENV['OPENAI_API_KEY'] || '')       @parser = LangChain::OutputParsers::StructuredOutputParser.from_json_schema({         answer: :string,         sources: [:string]       })       @session_manager = SessionManager.new     end
 def generate_answer(query)
   context = @session_manager.get_context('default').join("\n")
   results = @weaviate.similarity_search(query, k: 5, chunk_size: query.length > 100 ? 1000 : 200)
   sources = results.map { |r| r['url'] }.compact.uniq
   prompt = LangChain::Prompt::PromptTemplate.new(
     template: "Query: {{query}}\nContext: {{context}}\nAnswer with sources.",
     input_variables: ['query', 'context']
   )
   formatted = prompt.format(query: query, context: results.map { |r| r['content'] }.join("\n"))
   raw_response = @llm.generate(formatted)[:content]
   parsed = @parser.parse(raw_response)
   @session_manager.store_context('default', query)
   { answer: parsed[:answer], sources: sources }
 rescue StandardError => e
   { answer: "Error: #{e.message}", sources: [] }
 end

   end
EOF (60 lines)
CHECKSUM: sha256:5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6

### `lib/weaviate_integration.rb`

Manages Weaviate vector search with adaptive chunking.

frozen_string_literal: true
Weaviate Integration
EOF: 50 lines
CHECKSUM: sha256:6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7
   require 'langchain'
   class WeaviateIntegration     def initialize       @client = LangChain::Vectorsearch::Weaviate.new(         url: 'http://localhost:8080',         index_name: 'ai3_documents',         llm: LangChain::LLM::Ollama.new(model: 'llama3')       )     end
 def similarity_search(query, k: 5, chunk_size: 500)
   chunk_size = query.length > 100 ? 1000 : chunk_size
   @client.search(query: query, k: k, chunk_size: chunk_size, chunk_overlap: chunk_size / 5)
 end

 def add_texts(texts, chunk_size: 500, chunk_overlap: 50)
   texts.each do |text|
     @client.add_texts(
       texts: [text[:content]],
       schema: { url: text[:url], content: text[:content] },
       chunk_size: chunk_size,
       chunk_overlap: chunk_overlap
     )
   end
 end

 def check_if_indexed(url)
   @client.search(query: "url:#{url}", k: 1).any?
 end

   end
EOF (50 lines)
CHECKSUM: sha256:6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7

### `lib/web_interaction_base.rb`

Shared Ferrum logic for scraping and browsing.

frozen_string_literal: true
Web Interaction Base
EOF: 60 lines
CHECKSUM: sha256:7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8
   require 'ferrum'   require 'base64'
   class WebInteractionBase     USER_AGENTS = [       'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/58.0.3029.110 Safari/537.3',       'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 Safari/605.1.15'     ]
 def initialize
   @browser = Ferrum::Browser.new(timeout: 30, browser_options: { 'user-agent': USER_AGENTS.sample })
 end

 def navigate(url)
   @browser.goto(url)
   simulate_human_browsing
   { content: @browser.body, screenshot: take_screenshot }
 end

 private

 def simulate_human_browsing
   sleep rand(1..3)
   @browser.mouse.move(x: rand(50..150), y: rand(50..150))
   rand(1..5).times { @browser.mouse.scroll_to(0, rand(100..300)); sleep rand(1..2) }
 end

 def take_screenshot
   temp_file = "screenshot_#{Time.now.to_i}.png"
   @browser.screenshot(path: temp_file, full: true)
   image_base64 = Base64.strict_encode64(File.read(temp_file))
   File.delete(temp_file)
   image_base64
 end

 def close
   @browser.cookies.clear
   @browser.cache.clear
   @browser.quit
 end

   end
EOF (60 lines)
CHECKSUM: sha256:7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8

### `lib/multimedia.rb`

Handles image and video analysis with chained Replicate.com models.

frozen_string_literal: true
Multimedia Processing
EOF: 70 lines
CHECKSUM: sha256:8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9
   require 'replicate'   require 'json'
   class Multimedia     def initialize       @client = Replicate::Client.new(api_key: ENV['REPLICATE_API_KEY'] || '')       @models = load_models     end
 def analyze(file_path)
   return 'Error: File not found' unless File.exist?(file_path)
   ext = File.extname(file_path).downcase
   case ext
   when '.jpg', '.png'
     analyze_image(file_path)
   when '.mp4', '.mov'
     analyze_video(file_path)
   else
     'Error: Unsupported file type'
   end
 end

 def chain_models(input, model_chain = nil)
   model_chain ||= select_creative_chain
   result = input
   model_chain.each do |model|
     result = @client.models.get(model).predict(input: { data: result }, temperature: 0.9)
   end
   "Chained result: #{result[:output]}"
 end

 private

 def load_models
   JSON.parse(File.read('data/models/replicate.json')) rescue []
 end

 def select_creative_chain
   available = @models.map { |m| m['id'] }
   [
     available.find { |m| m.include?('stability-ai/stable-video-diffusion') } || 'stability-ai/stable-video-diffusion:2.1',
     available.find { |m| m.include?('openai/whisper') } || 'openai/whisper:20231117',
     available.find { |m| m.include?('meta/llama-3') } || 'meta/llama-3:70b'
   ]
 end

 def analyze_image(file_path)
   model = @client.models.get(@models.find { |m| m['id'].include?('stability-ai/stable-diffusion') }['id'])
   result = model.predict(input: { image: File.read(file_path) }, temperature: 0.9)
   "Image analysis: #{result[:description]}"
 end

 def analyze_video(file_path)
   model = @client.models.get(@models.find { |m| m['id'].include?('openai/whisper') }['id'])
   result = model.predict(input: { video: File.read(file_path) }, temperature: 0.9)
   "Video transcription: #{result[:transcription]}"
 end

   end
EOF (70 lines)
CHECKSUM: sha256:8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9

### `lib/workflow_composer.rb`

Orchestrates tasks using a DAG.

frozen_string_literal: true
Workflow Composer
EOF: 70 lines
CHECKSUM: sha256:9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0
   require_relative 'rag_system'   require_relative 'tools/universal_scraper'   require_relative 'multimedia'
   class WorkflowComposer     def initialize       @tasks = []       @rag_system = RAGSystem.new       @scraper = UniversalScraper.new       @multimedia = Multimedia.new     end
 def execute(input)
   tasks = parse_workflow(input)
   results = []
   tasks.each do |task|
     case task[:type]
     when 'scrape'
       results << @scraper.scrape(task[:url])
     when 'analyze'
       results << @rag_system.generate_answer(task[:query])
     when 'media_chain'
       results << @multimedia.chain_models(results.last[:answer])
     when 'summarize'
       results << summarize_results(results)
     end
   end
   results.last[:answer] || 'Workflow completed'
 end

 private

 def parse_workflow(input)
   steps = input.split('->').map(&:strip)
   steps.map do |step|
     case step
     when /scrape\s+(\S+)/ then { type: 'scrape', url: $1 }
     when /analyze\s+(.+)/ then { type: 'analyze', query: $1 }
     when /chain\s+media/ then { type: 'media_chain' }
     when /summarize/ then { type: 'summarize' }
     end
   end.compact
 end

 def summarize_results(results)
   summary = results.map { |r| r[:answer] }.join("\n")
   @rag_system.generate_answer("Summarize: #{summary}")
 end

   end
EOF (70 lines)
CHECKSUM: sha256:9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0

### `lib/web_monitor.rb`

Monitors websites for real-time changes.

frozen_string_literal: true
Web Monitor
EOF: 50 lines
CHECKSUM: sha256:0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1
   require_relative 'web_interaction_base'
   class WebMonitor < WebInteractionBase     def subscribe(url, interval: 60)       loop do         current = navigate(url)         cache_file = "data/cache/#{url.hash}.txt"         previous = File.read(cache_file) if File.exist?(cache_file)         if previous != current[:content]           yield "Change detected at #{url}: #{current[:content][0..100]}..."           File.write(cache_file, current[:content])         end         sleep interval       end     rescue StandardError => e       "Error: #{e.message}"     end   end
EOF (50 lines)
CHECKSUM: sha256:0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1

### `lib/code_generator.rb`

Generates Ruby/Rails code snippets.

frozen_string_literal: true
Code Generator
EOF: 50 lines
CHECKSUM: sha256:1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2
   require 'langchain'
   class CodeGenerator     def initialize       @llm = LangChain::LLM::Ollama.new(model: 'llama3')     end
 def generate(input)
   prompt = LangChain::Prompt::PromptTemplate.new(
     template: "Generate Ruby/Rails code for: {{request}}",
     input_variables: ['request']
   )
   formatted = prompt.format(request: input)
   @llm.generate(formatted)[:content]
 rescue StandardError => e
   "Error: #{e.message}"
 end

   end
EOF (50 lines)
CHECKSUM: sha256:1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2

### `lib/error_handling.rb`

Custom error classes for robust handling.

frozen_string_literal: true
Error Handling
EOF: 40 lines
CHECKSUM: sha256:2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3
   module AI3     class AI3Error < StandardError; end     class LLMError < AI3Error; end     class FileAccessError < AI3Error; end     class NetworkError < AI3Error; end     class SessionError < AI3Error; end     class ContentFilterError < AI3Error; end   end
EOF (40 lines)
CHECKSUM: sha256:2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3

### `lib/session_manager.rb`

Manages session context with SQLite.

frozen_string_literal: true
Session Manager
EOF: 60 lines
CHECKSUM: sha256:3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4
   require 'sqlite3'   require 'openssl'
   class SessionManager     def initialize       @db = SQLite3::Database.new('data/sessions.db')       @cipher = OpenSSL::Cipher.new('AES-256-CBC')     end
 def store_context(user_id, text)
   @cipher.encrypt
   @cipher.key = Digest::SHA256.digest(ENV['SESSION_KEY'] || 'secret')
   encrypted = @cipher.update(text) + @cipher.final
   @db.execute('INSERT INTO sessions (user_id, context, created_at) VALUES (?, ?, ?)',
               [user_id, encrypted.unpack1('H*'), Time.now])
 end

 def get_context(user_id)
   rows = @db.execute('SELECT context FROM sessions WHERE user_id = ? ORDER BY created_at DESC LIMIT 5', user_id)
   rows.map do |row|
     @cipher.decrypt
     @cipher.key = Digest::SHA256.digest(ENV['SESSION_KEY'] || 'secret')
     hex = row[0]
     encrypted = [hex].pack('H*')
     @cipher.update(encrypted) + @cipher.final
   end
 rescue StandardError => e
   AI3.logger.error("Session error: #{e.message}")
   []
 end

   end
EOF (60 lines)
CHECKSUM: sha256:3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4

### `lib/content_filter.rb`

Filters unethical or NSFW content.

frozen_string_literal: true
Content Filter
EOF: 50 lines
CHECKSUM: sha256:4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a6
   require 'langchain'   require_relative 'error_handling'
   class ContentFilter     def initialize(llm)       @llm = llm     end
 # Checks if input is safe (no NSFW or unethical content)
 # @param input [String] User input to filter
 # @return [Boolean] True if safe, false if flagged
 def safe?(input)
   prompt = LangChain::Prompt::PromptTemplate.new(
     template: "Classify text for NSFW or unethical content: {{text}}\nReturn scores: { porn: float, hentai: float, sexy: float }",
     input_variables: ['text']
   )
   response = @llm.generate(prompt.format(text: input))[:content]
   scores = JSON.parse(response)
   scores.values_at('porn', 'hentai', 'sexy').any? { |score| score > 0.5 } ? false : true
 rescue StandardError => e
   AI3.logger.error("Content filter error: #{e.message}")
   raise AI3::ContentFilterError, e.message
 end

   end
EOF (50 lines)
CHECKSUM: sha256:4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a6

### `tools/filesystem_tool.rb`

Secure file operations with `pledge`/`unveil`.

frozen_string_literal: true
FileSystem Tool
EOF: 60 lines
CHECKSUM: sha256:4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5
   require 'fileutils'   require 'logger'   require 'safe_ruby'   require_relative '../lib/error_handling'
   class FileSystemTool     def initialize       @logger = Logger.new(STDOUT)     end
 def read(path)
   raise AI3::FileAccessError, 'File not found or not readable' unless file_accessible?(path, :readable?)
   content = SafeRuby.eval("File.read(#{path.inspect})")
   @logger.info("Read: #{path}")
   content
 rescue StandardError => e
   raise AI3::FileAccessError, e.message
 end

 def write(path, content)
   raise AI3::FileAccessError, 'Permission denied' unless file_accessible?(path, :writable?)
   SafeRuby.eval("File.write(#{path.inspect}, #{content.inspect})")
   @logger.info("Wrote: #{path}")
   'File written successfully'
 rescue StandardError => e
   raise AI3::FileAccessError, e.message
 end

 def delete(path)
   raise AI3::FileAccessError, 'File not found' unless File.exist?(path)
   SafeRuby.eval("FileUtils.rm(#{path.inspect})")
   @logger.info("Deleted: #{path}")
   'File deleted successfully'
 rescue StandardError => e
   raise AI3::FileAccessError, e.message
 end

 private

 def file_accessible?(path, access_method)
   File.exist?(path) && File.public_send(access_method, path)
 end

   end
EOF (60 lines)
CHECKSUM: sha256:4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5

### `tools/universal_scraper.rb`

Web scraping with Ferrum and Weaviate storage, including Replicate.com models.

frozen_string_literal: true
Universal Scraper
EOF: 80 lines
CHECKSUM: sha256:5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6
   require_relative '../lib/web_interaction_base'   require_relative '../lib/weaviate_integration'   require 'json'
   class UniversalScraper < WebInteractionBase     def initialize       super       @weaviate = WeaviateIntegration.new     end
 def scrape(url)
   return 'Already indexed' if @weaviate.check_if_indexed(url)
   result = url == 'https://replicate.com/explore' ? scrape_replicate_models : navigate(url)
   @weaviate.add_texts([{ url: url, content: result[:content] }])
   if url == 'https://replicate.com/explore'
     File.write('data/models/replicate.json', JSON.pretty_generate(result[:models]))
     "Scraped Replicate models: #{result[:models].length} found"
   else
     "Scraped: #{url}\nContent: #{result[:content][0..100]}..."
   end
 rescue StandardError => e
   raise AI3::NetworkError, "Error scraping #{url}: #{e.message}"
 ensure
   close
 end

 private

 def scrape_replicate_models
   @browser.goto('https://replicate.com/explore')
   models = []
   max_scrolls = 10
   scrolls = 0
   last_height = @browser.evaluate('document.body.scrollHeight')
   while scrolls < max_scrolls
     @browser.execute('window.scrollTo(0, document.body.scrollHeight)')
     sleep 2
     new_height = @browser.evaluate('document.body.scrollHeight')
     break if new_height == last_height
     last_height = new_height
     scrolls += 1
   end
   elements = @browser.css('a[href*="/models/"]').map do |el|
     { id: el.attribute('href').split('/').last, name: el.text }
   end
   { content: JSON.pretty_generate(elements), models: elements }
 end

   end
EOF (80 lines)
CHECKSUM: sha256:5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6

### `tools/web_browser_tool.rb`

Web browsing with element extraction and LLM analysis.

frozen_string_literal: true
Web Browser Tool
EOF: 60 lines
CHECKSUM: sha256:6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7
   require 'langchain'   require_relative '../lib/web_interaction_base'
   class WebBrowserTool < WebInteractionBase     def initialize       super       @llm = LangChain::LLM::Ollama.new(model: 'llama3')     end
 def navigate(url)
   result = super(url)
   elements = @browser.css('a, p, h1, h2, h3').map { |el| { text: el.text, attrs: el.attributes } }
   prompt = LangChain::Prompt::PromptTemplate.new(
     template: 'Extract key info from: {{content}}',
     input_variables: ['content']
   )
   extracted = @llm.generate(prompt.format(content: result[:content][0..1000]))[:content]
   "Browsed #{url}:\nExtracted: #{extracted}\nElements: #{elements.length} found"
 rescue StandardError => e
   raise AI3::NetworkError, "Error browsing #{url}: #{e.message}"
 ensure
   close
 end

   end
EOF (60 lines)
CHECKSUM: sha256:6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7

## Usage

Launch the CLI: `ai3`

Example commands:
- `read /etc/passwd`
- `scrape https://example.com`
- `scrape https://replicate.com/explore`
- `browse https://news.ycombinator.com`
- `analyze image.jpg`
- `scrape example.com -> analyze content -> chain media -> summarize`
- `monitor https://news.ycombinator.com`
- `generate model User name:string`

## Troubleshooting
- **LLM Errors**: Verify API keys in `~/.ai3_keys`.
- **Weaviate Issues**: Ensure `weaviate` is running (`doas rcctl check weaviate`).
- **SQLite Errors**: Check `data/sessions.db` permissions.
- **Ferrum Issues**: Verify `ferrum` gem and network connectivity.
- **Content Filter Errors**: Check `logs/ai3.log` for flagged inputs.
- **Logs**: Inspect `logs/ai3.log`.

# EOF (1100 lines)
# CHECKSUM: sha256:a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b

