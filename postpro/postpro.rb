#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Postpro.rb transforms images with analog and cinematic effects.
# Version: 13.4.27
# Updated: 2025-04-26
# Requires: ruby-vips (>= 2.1.0), tty-prompt, objspace
# Compatible with: libvips 8.14.3
#
# Applies fixes for zero-band crashes, memory leaks, band mismatches, recipe overwrites,
# and performance issues. Adds permission checks, improved error messages, and memory logging.

require "vips"
require "logger"
require "tty-prompt"
require "json"
require "time"
require "fileutils"
require "securerandom"
require "objspace"

# Initialize logging and clean CWD with permission checks
if File.writable?(Dir.pwd)
  File.write("postpro.log", "") if File.exist?("postpro.log")
  FileUtils.rm(Dir.glob("*.json"), force: true)
  FileUtils.rm(Dir.glob("*processed*"), force: true)
else
  raise Errno::EACCES, "No write permission in current directory"
end
$logger = Logger.new("postpro.log", "daily", level: Logger::DEBUG)
$logger = Logger.new(STDERR) if $logger.nil?
$cli_logger = Logger.new(STDOUT, level: Logger::INFO)
PROMPT = TTY::Prompt.new
$logger.debug "Initialized: log reset, CWD cleaned"

# 256-color web palette LUT (cached)
WEB_PALETTE = Vips::Image.new_from_array(
  Array.new(256) { |i| [i % 8 * 32, (i / 8) % 8 * 32, (i / 64) * 32] }.flatten.each_slice(3).to_a
).freeze

# Read-only effect configuration
# @return [Hash<String, Symbol>] Mapping of effect names to method symbols
EFFECTS = {
  "film_grain" => :film_grain,
  "optical_flare" => :optical_flare,
  "lens_distortion" => :lens_distortion,
  "sepia" => :sepia,
  "bleach_bypass" => :bleach_bypass,
  "lomo" => :lomo,
  "golden_hour_glow" => :golden_hour_glow,
  "cross_process" => :cross_process,
  "bloom_effect" => :bloom_effect,
  "film_halation" => :film_halation,
  "teal_and_orange" => :teal_and_orange,
  "day_for_night" => :day_for_night,
  "anamorphic_simulation" => :anamorphic_simulation,
  "chromatic_aberration" => :chromatic_aberration,
  "vhs_artifact" => :vhs_artifact,
  "tone_grading" => :tone_grading,
  "soft_focus" => :soft_focus,
  "double_exposure" => :double_exposure,
  "polaroid_frame" => :polaroid_frame,
  "tape_degradation" => :tape_degradation,
  "frame_distortion" => :frame_distortion,
  "super8_flicker" => :super8_flicker,
  "cinemascope_bars" => :cinemascope_bars,
  "halftone_print" => :halftone_print,
  "film_scratches" => :film_scratches,
  "film_stock_emulation" => :film_stock_emulation,
  "surface_imperfections" => :surface_imperfections,
  "glitch" => :glitch,
  "neon_glow" => :neon_glow,
  "pixel_sorting" => :pixel_sorting,
  "lens_prism" => :lens_prism,
  "static_noise" => :static_noise,
  "emulsion_layering" => :emulsion_layering,
  "temporal_wear" => :temporal_wear,
  "spectral_color_drift" => :spectral_color_drift
}.freeze

EXPERIMENTAL_EFFECTS = %w[
  vhs_artifact tape_degradation super8_flicker glitch chromatic_aberration
  surface_imperfections neon_glow pixel_sorting lens_prism static_noise
  emulsion_layering temporal_wear spectral_color_drift
].freeze

BRIGHTNESS_ALTERING_EFFECTS = %w[
  day_for_night tone_grading bloom_effect bleach_bypass spectral_color_drift
].freeze

PARAM_RANGES = {
  "double_exposure" => { "blend_mode" => %w[over add multiply] },
  "polaroid_frame" => { "border_style" => %w[classic worn] },
  "cinemascope_bars" => { "aspect_ratio" => %w[2.35:1 1.85:1] },
  "film_stock_emulation" => { "stock_type" => %w[kodak_portra fuji_velvia] },
  "tone_grading" => { "grade_type" => %w[red_dominant blue_dominant green_dominant neutral] },
  "temporal_wear" => { "age" => %w[recent aged ancient] }
}.freeze

# Track used effects and shared noise (limited to 10 entries)
USED_EFFECTS = Hash.new { |h, k| h[k] = [] }
SHARED_NOISE = {}
MAX_NOISE_CACHE = 10

# Gets or generates shared noise texture with size validation
# @param width [Integer] Image width
# @param height [Integer] Image height
# @param scale [Integer] Noise scale
# @return [Vips::Image] Noise texture
def get_shared_noise(width, height, scale)
  return Vips::Image.black(width, height) if width > 10000 || height > 10000 || scale < 1
  key = "#{width}x#{height}_#{scale}"
  SHARED_NOISE[key] ||= Vips::Image.perlin(width / scale, height / scale).resize(scale)
  SHARED_NOISE.shift if SHARED_NOISE.size > MAX_NOISE_CACHE
  SHARED_NOISE[key]
rescue Vips::Error => e
  $logger.error "Failed to generate noise: #{e.message}"
  Vips::Image.black(width, height)
end

# Selects random effects
# @param count [Integer] Number of effects
# @param mode [String] Processing mode
# @param file [String] Input file path
# @return [Array<Symbol>] Selected effects
def random_effects(count, mode, file)
  available = EFFECTS.keys - USED_EFFECTS[file]
  available = EFFECTS.keys if available.empty?
  count = [count, available.size].min

  mood = %w[warm cool neutral].sample
  $logger.debug "Selected mood: #{mood}"

  selected = available.shuffle.take(count)
  selected = (selected & EXPERIMENTAL_EFFECTS).shuffle.take(count / 2) + (selected - EXPERIMENTAL_EFFECTS).shuffle.take(count - count / 2) if mode == "experimental"

  selected = selected.map do |effect|
    case mood
    when "warm" then %w[golden_hour_glow sepia optical_flare].include?(effect) ? effect : effect
    when "cool" then %w[day_for_night teal_and_orange spectral_color_drift].include?(effect) ? effect : effect
    else effect
    end
  end

  selected = selected.map(&:to_sym).uniq
  USED_EFFECTS[file] += selected
  $logger.debug "Selected effects: #{selected}"
  selected
end

# Generates random intensity
# @param mode [String] Processing mode
# @return [Float] Random intensity
def random_intensity(mode)
  mode == "experimental" ? rand(0.2..0.6) : rand(0.1..0.4)
end

# Loads and prepares image
# @param file [String] Input file path
# @return [Vips::Image, nil] Loaded image or nil
def load_image(file)
  $logger.debug "Loading '#{file}'"
  unless File.exist?(file) && File.readable?(file)
    $cli_logger.error "Cannot load '#{file}': File does not exist or is not readable"
    return nil
  end

  image = Vips::Image.new_from_file(file)
  if image.bands == 0
    $cli_logger.error "Cannot process '#{file}': Image has zero bands"
    return nil
  end
  $logger.debug "Loaded '#{file}': #{image.width}x#{image.height}, #{image.bands} bands, avg: #{image.avg}"

  image = image.colourspace("srgb") if image.bands < 3
  image = image.extract_band(0, n: 3) if image.bands > 3
  image
rescue Vips::Error => e
  $cli_logger.error "Failed to load '#{file}': Invalid or corrupted image (#{e.message})"
  nil
rescue StandardError => e
  $logger.error "Unexpected error loading '#{file}': #{e.message}"
  nil
end

# Preserves brightness
# @param image [Vips::Image] Input image
# @return [Vips::Image] Adjusted image
def preserve_brightness(image)
  return image if image.bands == 0
  avg = image.avg
  $logger.debug "Preserving brightness, avg: #{avg}"
  return image if avg.between?(80, 180)

  factor = avg < 80 ? (90 - avg) / 255.0 : (avg - 170) / 255.0
  image = image.linear([1 + factor], [avg < 80 ? 5 : -5]).cast("uchar")
  $logger.debug "Adjusted brightness, new avg: #{image.avg}"
  image
rescue StandardError => e
  $logger.error "Failed in preserve_brightness: #{e.message}"
  image
end

# Applies effects with batching and lazy evaluation
# @param image [Vips::Image] Input image
# @param effects_array [Array<Symbol>] Effects to apply
# @param mode [String] Processing mode
# @return [Hash] Processed image and applied effects
def apply_effects(image, effects_array, mode)
  return { image: image, applied_effects: [] } if image.bands == 0
  image = image.colourspace("srgb") if image.bands == 1
  $logger.debug "Applying effects, avg: #{image.avg}, bands: #{image.bands}"
  original_avg = image.avg
  applied_effects = []
  processing_queue = { color: [], blur: [], noise: [], other: [] }

  effects_array.shuffle.each do |effect|
    effect_str = effect.to_s
    unless EFFECTS.key?(effect_str)
      $logger.warn "Skipping unknown effect: #{effect}"
      next
    end

    intensity = random_intensity(mode)
    $cli_logger.info "Queuing #{effect} (intensity: #{intensity.round(2)})"
    case effect_str
    when "sepia", "tone_grading", "teal_and_orange", "spectral_color_drift"
      processing_queue[:color] << { effect: effect, intensity: intensity }
    when "bloom_effect", "film_halation", "soft_focus"
      processing_queue[:blur] << { effect: effect, intensity: intensity }
    when "film_grain", "surface_imperfections", "static_noise", "emulsion_layering"
      processing_queue[:noise] << { effect: effect, intensity: intensity }
    else
      processing_queue[:other] << { effect: effect, intensity: intensity }
    end
    applied_effects << { effect: effect_str, intensity: intensity.round(2) }
  end

  # Batch color effects
  unless processing_queue[:color].empty?
    matrix = [1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0]
    offset = [0.0, 0.0, 0.0]
    processing_queue[:color].each do |effect_data|
      effect, intensity = effect_data[:effect], effect_data[:intensity]
      case effect
      when :sepia
        matrix[0] += 0.1 * intensity
        matrix[4] += 0.05 * intensity
        matrix[8] -= 0.05 * intensity
      when :tone_grading
        matrix[0] += 0.1 * intensity
        matrix[4] -= 0.05 * intensity
        matrix[8] += 0.1 * intensity
      when :teal_and_orange
        matrix[0] += 0.1 * intensity
        matrix[8] += 0.15 * intensity
      when :spectral_color_drift
        matrix[0] += rand(-0.1..0.1) * intensity
        matrix[4] += rand(-0.1..0.1) * intensity
        matrix[8] += rand(-0.1..0.1) * intensity
      end
    end
    image = image.recomb(matrix).linear([1.0], offset).cast("uchar")
    $logger.debug "Batched color effects, avg: #{image.avg}"
  end

  # Apply blur effects
  processing_queue[:blur].each do |effect_data|
    effect, intensity = effect_data[:effect], effect_data[:intensity]
    image = send(effect, image, intensity, mode)
    image = image.extract_band(0, n: 3) if image.bands > 3
    $logger.debug "After #{effect}: avg #{image.avg}, bands #{image.bands}"
  end

  # Apply noise effects
  processing_queue[:noise].each do |effect_data|
    effect, intensity = effect_data[:effect], effect_data[:intensity]
    image = send(effect, image, intensity, mode)
    image = image.extract_band(0, n: 3) if image.bands > 3
    $logger.debug "After #{effect}: avg #{image.avg}, bands #{image.bands}"
  end

  # Apply other effects
  processing_queue[:other].each do |effect_data|
    effect, intensity = effect_data[:effect], effect_data[:intensity]
    image = send(effect, image, intensity, mode)
    image = image.extract_band(0, n: 3) if image.bands > 3
    $logger.debug "After #{effect}: avg #{image.avg}, bands #{image.bands}"
  end

  image = preserve_brightness(image)
  final_change = (image.avg - original_avg).round(2)
  $logger.debug "Effects applied, final avg: #{image.avg}, change: #{final_change}"
  { image: image, applied_effects: applied_effects }
rescue StandardError => e
  $logger.error "Failed in apply_effects: #{e.message}"
  { image: image, applied_effects: applied_effects }
end

# Applies effects from JSON recipe
# @param image [Vips::Image] Input image
# @param recipe [Hash] JSON recipe
# @param mode [String] Processing mode
# @return [Hash] Processed image and applied effects
def apply_effects_from_recipe(image, recipe, mode)
  return { image: image, applied_effects: [] } if image.bands == 0
  image = image.colourspace("srgb") if image.bands == 1
  $logger.debug "Applying recipe, avg: #{image.avg}, bands: #{image.bands}"
  original_avg = image.avg
  applied_effects = []

  recipe.each do |effect, params|
    effect_str = effect.to_s
    next unless EFFECTS.key?(effect_str)

    intensity = params.is_a?(Hash) ? params["intensity"].to_f : params.to_f
    $cli_logger.info "Applying recipe #{effect} (intensity: #{intensity.round(2)})"
    $logger.debug "Before #{effect}: avg #{image.avg}, bands #{image.bands}"

    image = send(effect_str, image, intensity, mode, params)
    image = image.extract_band(0, n: 3) if image.bands > 3
    change = (image.avg - original_avg).round(2)
    $logger.debug "After #{effect}: avg #{image.avg}, change #{change}"
    applied_effects << { effect: effect_str, intensity: intensity.round(2) }
  end

  image = preserve_brightness(image)
  $logger.debug "Recipe complete, final avg: #{image.avg}"
  { image: image, applied_effects: applied_effects }
rescue StandardError => e
  $logger.error "Failed to apply recipe: #{e.message}"
  { image: image, applied_effects: applied_effects }
end

# Adds layered film grain
# @param image [Vips::Image] Input image
# @param intensity [Float] Effect intensity
# @param mode [String] Processing mode
# @param params [Hash] Optional parameters
# @return [Vips::Image] Processed image
def film_grain(image, intensity, mode, params = {})
  return image if image.bands == 0
  scale = mode == "professional" ? rand(10..20) : rand(20..30)
  $logger.debug "Applying film grain, scale: #{scale}"

  noise = get_shared_noise(image.width, image.height, scale)
  noise = noise.bandjoin([noise] * (image.bands - 1)) if noise.bands < image.bands
  opacity = mode == "professional" ? 0.3 : 0.4
  image = (image + noise * intensity * opacity).cast("uchar")
  $logger.debug "Film grain applied, avg: #{image.avg}"
  image
end

# Adds light-based flares
def optical_flare(image, intensity, mode, params = {})
  return image if image.bands == 0
  overlay = Vips::Image.black(image.width, image.height, bands: image.bands)
  count = mode == "professional" ? rand(3..5) : rand(5..7)
  $logger.debug "Applying #{count} optical flares"

  count.times do
    x, y = rand(image.width), rand(image.height)
    size = image.width / rand(3..5)
    color = mode == "professional" ? [200 * intensity, 100 * intensity, 50 * intensity] : [255 * intensity, rand(150..200) * intensity, rand(50..100) * intensity]
    overlay = overlay.draw_circle(color, x, y, size, fill: true)
  end

  image = (image + overlay.gaussblur(intensity * 0.2) * 0.1).cast("uchar")
  $logger.debug "Optical flare applied, avg: #{image.avg}"
  image
end

# Applies lens distortion
def lens_distortion(image, intensity, mode, params = {})
  return image if image.bands == 0
  factor = mode == "professional" ? rand(0.1..0.3) * intensity : rand(0.3..0.5) * intensity
  $logger.debug "Applying lens distortion, factor: #{factor}"

  identity = Vips::Image.identity.uint8(image.width, image.height)
  dx = identity.linear(factor, -intensity * rand(1..3)).cast("float")
  dy = identity.linear(factor, -intensity * rand(1..3)).cast("float")
  image = image.mapim(dx.bandjoin(dy))
  $logger.debug "Lens distortion applied, avg: #{image.avg}"
  image
end

# Adds sepia tone
def sepia(image, intensity, mode, params = {})
  return image if image.bands == 0
  shift = mode == "professional" ? 0.1 * intensity : 0.2 * intensity
  $logger.debug "Applying sepia, shift: #{shift}"

  matrix = [
    0.9 + shift, 0.7 - shift / 2, 0.2,
    0.3, 0.8 + shift / 2, 0.15 - shift / 2,
    0.25 - shift / 2, 0.6, 0.1 + shift
  ]
  image = image.recomb(matrix).cast("uchar")
  $logger.debug "Sepia applied, avg: #{image.avg}"
  image
end

# Creates high-contrast, desaturated look
def bleach_bypass(image, intensity, mode, params = {})
  return image if image.bands == 0
  blend_factor = mode == "professional" ? rand(0.4..0.6) : rand(0.6..0.8)
  $logger.debug "Applying bleach bypass, blend_factor: #{blend_factor}"

  gray = image.colourspace("grey16").cast("uchar")
  image = (image * (1 - blend_factor * intensity) + gray * blend_factor * intensity).linear([1.1], [5 * intensity]).cast("uchar")
  $logger.debug "Bleach bypass applied, avg: #{image.avg}"
  image
end

# Boosts saturation with blur
def lomo(image, intensity, mode, params = {})
  return image if image.bands == 0
  sat_factor = mode == "professional" ? rand(0.2..0.4) * intensity : rand(0.4..0.6) * intensity
  $logger.debug "Applying lomo, sat_factor: #{sat_factor}"

  image = image.linear([1.0 + sat_factor], [0]).gaussblur(intensity * 0.2).cast("uchar")
  $logger.debug "Lomo applied, avg: #{image.avg}"
  image
end

# Adds warm tint
def golden_hour_glow(image, intensity, mode, params = {})
  return image if image.bands == 0
  color = mode == "professional" ? [200 * intensity, 160 * intensity, 120 * intensity] : [255 * intensity, rand(180..220) * intensity, rand(150..180) * intensity]
  $logger.debug "Applying golden hour glow"

  overlay = Vips::Image.new_from_array([color], image.height, image.width).gaussblur(intensity * 0.3)
  image = (image + overlay * 0.1).cast("uchar")
  $logger.debug "Golden hour glow applied, avg: #{image.avg}"
  image
end

# Simulates cross-processed film
def cross_process(image, intensity, mode, params = {})
  return image if image.bands == 0
  r, g, b = image.bandsplit
  shifts = mode == "professional" ? [rand(0.2..0.4), rand(0.1..0.2), rand(0.3..0.5)] : [rand(0.4..0.6), rand(0.2..0.3), rand(0.5..0.7)]
  $logger.debug "Applying cross process, shifts: #{shifts}"

  r = r.linear([1 + shifts[0] * intensity], [rand(5..10) * intensity])
  g = g.linear([1 - shifts[1] * intensity], [0])
  b = b.linear([1 + shifts[2] * intensity], [-rand(3..6) * intensity])
  image = Vips::Image.bandjoin([r, g, b]).cast("uchar")
  $logger.debug "Cross process applied, avg: #{image.avg}"
  image
end

# Boosts brightness with blur
def bloom_effect(image, intensity, mode, params = {})
  return image if image.bands == 0
  boost = mode == "professional" ? rand(1.2..1.3) * intensity : rand(1.3..1.5) * intensity
  $logger.debug "Applying bloom, boost: #{boost}"

  bright = image.linear([boost], [0]).gaussblur(intensity * 0.3)
  image = (image + bright * 0.1).cast("uchar")
  $logger.debug "Bloom effect applied, avg: #{image.avg}"
  image
end

# Boosts highlights with blur
def film_halation(image, intensity, mode, params = {})
  return image if image.bands == 0
  highlights = image > rand(180..220)
  blur_radius = mode == "professional" ? intensity * 0.15 : intensity * 0.25
  $logger.debug "Applying film halation, blur_radius: #{blur_radius}"

  halo = highlights.gaussblur(blur_radius).linear(0.05 * intensity, 0)
  halo = halo.bandjoin([halo] * (image.bands - 1)) if halo.bands < image.bands
  image = (image + halo * 0.1).cast("uchar")
  $logger.debug "Film halation applied, avg: #{image.avg}"
  image
end

# Applies teal-orange grade
def teal_and_orange(image, intensity, mode, params = {})
  return image if image.bands == 0
  r, g, b = image.bandsplit
  shifts = mode == "professional" ? [rand(0.2..0.4), rand(0.1..0.2), rand(0.3..0.5)] : [rand(0.4..0.6), rand(0.2..0.3), rand(0.5..0.7)]
  $logger.debug "Applying teal and orange, shifts: #{shifts}"

  r = r.linear([1 + shifts[0] * intensity], [rand(5..10) * intensity])
  g = g.linear([1 - shifts[1] * intensity], [0])
  b = b.linear([1 + shifts[2] * intensity], [0])
  image = Vips::Image.bandjoin([r, g, b]).cast("uchar")
  $logger.debug "Teal and orange applied, avg: #{image.avg}"
  image
end

# Converts day to night
def day_for_night(image, intensity, mode, params = {})
  return image if image.bands == 0
  dark_factor = mode == "professional" ? rand(0.1..0.2) * intensity : rand(0.2..0.3) * intensity
  $logger.debug "Applying day for night, dark_factor: #{dark_factor}"

  darkened = image.linear([1 - dark_factor], [-rand(5..10) * intensity])
  r, g, b = darkened.bandsplit
  b = b.linear([1 + rand(0.1..0.2) * intensity], [rand(5..8) * intensity])
  image = Vips::Image.bandjoin([r, g, b]).cast("uchar")
  $logger.debug "Day for night applied, avg: #{image.avg}"
  image
end

# Mimics anamorphic stretch
def anamorphic_simulation(image, intensity, mode, params = {})
  return image if image.bands == 0
  stretch = mode == "professional" ? rand(0.1..0.2) * intensity : rand(0.2..0.3) * intensity
  $logger.debug "Applying anamorphic simulation, stretch: #{stretch}"

  image = image.resize(1.0 + stretch, vscale: rand(0.95..1.05))
  $logger.debug "Anamorphic simulation applied, avg: #{image.avg}"
  image
end

# Adds color fringing
def chromatic_aberration(image, intensity, mode, params = {})
  return image if image.bands == 0
  shift = mode == "professional" ? rand(1.0..2.0) * intensity : rand(2.0..3.0) * intensity
  $logger.debug "Applying chromatic aberration, shift: #{shift}"

  r, g, b = image.bandsplit
  r = r.wrap(shift.to_i, rand(-shift..shift).to_i)
  b = b.wrap(-shift.to_i, rand(-shift..shift).to_i)
  image = Vips::Image.bandjoin([r, g, b]).cast("uchar")
  $logger.debug "Chromatic aberration applied, avg: #{image.avg}"
  image
end

# Emulates VHS noise and misalignment
def vhs_artifact(image, intensity, mode, params = {})
  return image if image.bands == 0
  sigma = mode == "professional" ? rand(15..25) * intensity : rand(25..35) * intensity
  $logger.debug "Applying VHS artifact, sigma: #{sigma}"

  noise = get_shared_noise(image.width, image.height, rand(10..20))
  r, g, b = image.bandsplit
  r = r.wrap(rand(1..3), 0)
  b = b.wrap(rand(-3..-1), 0)
  image_shifted = Vips::Image.bandjoin([r, g, b])
  noise = noise.bandjoin([noise] * (image.bands - 1)) if noise.bands < image.bands
  image = (image_shifted + noise * 0.2).cast("uchar").gaussblur(intensity * 0.2)
  $logger.debug "VHS artifact applied, avg: #{image.avg}"
  image
end

# Applies color grading
def tone_grading(image, intensity, mode, params = {})
  return image if image.bands == 0
  grade_type = params["grade_type"] || %w[red_dominant blue_dominant green_dominant neutral].sample
  $logger.debug "Applying tone grading, type: #{grade_type}"

  r, g, b = image.bandsplit
  case grade_type
  when "red_dominant"
    r = r.linear([1 + 0.1 * intensity], [10 * intensity])
    g = g.linear([1 - 0.05 * intensity], [0])
    b = b.linear([1 - 0.05 * intensity], [0])
  when "blue_dominant"
    r = r.linear([1 - 0.05 * intensity], [0])
    g = g.linear([1 - 0.05 * intensity], [0])
    b = b.linear([1 + 0.1 * intensity], [10 * intensity])
  when "green_dominant"
    r = r.linear([1 - 0.05 * intensity], [0])
    g = g.linear([1 + 0.1 * intensity], [10 * intensity])
    b = b.linear([1 - 0.05 * intensity], [0])
  else
    shadows = image < 128
    r = r - (shadows * 0.05 * intensity * 50)
    b = b + (shadows * 0.05 * intensity * 50)
  end
  image = Vips::Image.bandjoin([r, g, b]).cast("uchar")
  $logger.debug "Tone grading applied, avg: #{image.avg}"
  image
end

# Applies soft focus
def soft_focus(image, intensity, mode, params = {})
  return image if image.bands == 0
  blend_factor = mode == "professional" ? rand(0.4..0.6) : rand(0.6..0.8)
  $logger.debug "Applying soft focus, blend_factor: #{blend_factor}"

  blurred = image.gaussblur(intensity * 0.2)
  image = (image * (1 - blend_factor) + blurred * blend_factor).cast("uchar")
  $logger.debug "Soft focus applied, avg: #{image.avg}"
  image
end

# Blends image with itself
def double_exposure(image, intensity, mode, params = {})
  return image if image.bands == 0
  blend_mode = params["blend_mode"] || "over"
  $logger.debug "Applying double exposure, blend_mode: #{blend_mode}"

  second = image
  second = second.resize(image.width.to_f / second.width) if second.width != image.width
  image = (image + second * rand(0.2..0.4)).cast("uchar")
  $logger.debug "Double exposure applied, avg: #{image.avg}"
  image
end

# Adds polaroid tint
def polaroid_frame(image, intensity, mode, params = {})
  return image if image.bands == 0
  border_style = params["border_style"] || "classic"
  $logger.debug "Applying polaroid frame, style: #{border_style}"

  frame_color = mode == "professional" ? [245, 245, 225] : [rand(240..255), rand(240..255), rand(220..240)]
  overlay = Vips::Image.new_from_array([frame_color], image.height, image.width).gaussblur(intensity * 0.2)
  image = (image + overlay * 0.1).cast("uchar")
  $logger.debug "Polaroid frame applied, avg: #{image.avg}"
  image
end

# Simulates tape degradation
def tape_degradation(image, intensity, mode, params = {})
  return image if image.bands == 0
  sigma = mode == "professional" ? rand(15..20) * intensity : rand(20..30) * intensity
  $logger.debug "Applying tape degradation, sigma: #{sigma}"

  noise = get_shared_noise(image.width, image.height, rand(10..20))
  warp_factor = mode == "professional" ? rand(0.2..0.4) * intensity : rand(0.4..0.6) * intensity
  warped = image.resize(1 + warp_factor, vscale: rand(0.95..1.05)).rotate(rand(-3..3) * intensity)
  noise = noise.bandjoin([noise] * (image.bands - 1)) if noise.bands < image.bands
  image = ((image + noise * 0.2) + warped * 0.2).cast("uchar").gaussblur(intensity * 0.2)
  $logger.debug "Tape degradation applied, avg: #{image.avg}"
  image
end

# Distorts frame
def frame_distortion(image, intensity, mode, params = {})
  return image if image.bands == 0
  angle = mode == "professional" ? rand(-10..10) * intensity : rand(-15..15) * intensity
  $logger.debug "Applying frame distortion, angle: #{angle}"

  rotated = image.rotate(angle)
  offset = (image.width * Math.sin(angle.abs * Math::PI / 180) / 2).to_i
  image = rotated.crop(offset, offset, image.width, image.height)
  $logger.debug "Frame distortion applied, avg: #{image.avg}"
  image
end

# Adds Super 8 flicker
def super8_flicker(image, intensity, mode, params = {})
  return image if image.bands == 0
  flicker = Vips::Image.black(image.width, image.height, bands: image.bands)
  count = mode == "professional" ? rand(5..8) : rand(8..12)
  $logger.debug "Applying #{count} super8 flickers"

  count.times do
    flicker = flicker.draw_rect([rand(80..120) * intensity] * image.bands, rand(image.width), rand(image.height), rand(20..40), rand(20..40), fill: true)
  end

  image = (image + flicker.gaussblur(intensity * 0.2) * 0.2).cast("uchar")
  $logger.debug "Super8 flicker applied, avg: #{image.avg}"
  image
end

# Applies cinemascope effect
def cinemascope_bars(image, intensity, mode, params = {})
  return image if image.bands == 0
  aspect_ratio = params["aspect_ratio"] || "2.35:1"
  $logger.debug "Applying cinemascope, aspect: #{aspect_ratio}"

  image = image.linear([1.0 - intensity * 0.1], [rand(5..10) * intensity]).gaussblur(intensity * 0.2).cast("uchar")
  $logger.debug "Cinemascope applied, avg: #{image.avg}"
  image
end

# Creates halftone effect
def halftone_print(image, intensity, mode, params = {})
  return image if image.bands == 0
  rank_size = mode == "professional" ? rand(8..12) : rand(12..16)
  $logger.debug "Applying halftone print, rank_size: #{rank_size}"

  grey = image.colourspace("grey16").cast("uchar")
  dots = grey.rank(rank_size, rank_size, rand(2..4)).linear([1.1 * intensity], [0])
  image = (image + dots * 0.2).cast("uchar")
  $logger.debug "Halftone print applied, avg: #{image.avg}"
  image
end

# Adds film scratches
def film_scratches(image, intensity, mode, params = {})
  return image if image.bands == 0
  scratches = Vips::Image.black(image.width, image.height, bands: image.bands)
  count = mode == "professional" ? rand(5..8) : rand(8..12)
  $logger.debug "Applying #{count} film scratches"

  count.times do
    x = rand(image.width)
    width = rand(1..3) * intensity
    scratches = scratches.draw_rect([rand(200..255) * intensity] * image.bands, x, 0, width, image.height, fill: true)
  end

  image = (image + scratches.gaussblur(intensity * 0.1) * 0.2).cast("uchar")
  $logger.debug "Film scratches applied, avg: #{image.avg}"
  image
end

# Emulates film stock
def film_stock_emulation(image, intensity, mode, params = {})
  return image if image.bands == 0
  stock_type = params["stock_type"] || %w[kodak_portra fuji_velvia].sample
  $logger.debug "Applying film stock: #{stock_type}"

  r, g, b = image.bandsplit
  if stock_type == "kodak_portra"
    r = r.linear([1 + 0.05 * intensity], [5 * intensity])
    g = g.linear([1 - 0.03 * intensity], [0])
    b = b.linear([1 - 0.04 * intensity], [-3 * intensity])
  else
    r = r.linear([1 + 0.1 * intensity], [10 * intensity])
    g = g.linear([1 + 0.05 * intensity], [0])
    b = b.linear([1 + 0.03 * intensity], [0])
  end
  image = Vips::Image.bandjoin([r, g, b]).linear([1 + rand(0.1..0.15)], [0]).cast("uchar")
  $logger.debug "Film stock emulation applied, avg: #{image.avg}"
  image
end

# Adds surface imperfections
def surface_imperfections(image, intensity, mode, params = {})
  return image if image.bands == 0
  stains = get_shared_noise(image.width, image.height, rand(10..20))
  count = mode == "professional" ? rand(3..5) : rand(5..7)
  $logger.debug "Applying #{count} surface imperfections"

  count.times do
    x, y = rand(image.width), rand(image.height)
    radius = image.width / rand(4..6)
    color = [rand(100..150) * intensity, rand(80..120) * intensity, rand(50..100) * intensity]
    stains = stains.draw_circle(color, x, y, radius, fill: true)
  end

  stains = stains.gaussblur(intensity * 0.2)
  image = (image + stains * 0.05).cast("uchar")
  $logger.debug "Surface imperfections applied, avg: #{image.avg}"
  image
end

# Creates glitch effects
def glitch(image, intensity, mode, params = {})
  return image if image.bands == 0
  shift = mode == "professional" ? rand(10..20) * intensity : rand(20..30) * intensity
  $logger.debug "Applying glitch, shift: #{shift}"

  r, g, b = image.bandsplit
  r = r.wrap(rand(-shift..shift).to_i, rand(-shift..shift).to_i)
  g = g.wrap(rand(-shift..shift).to_i, rand(-shift..shift).to_i)
  b = b.wrap(rand(-shift..shift).to_i, rand(-shift..shift).to_i)
  noise = get_shared_noise(image.width, image.height, rand(10..20))
  noise = noise.bandjoin([noise] * (image.bands - 1)) if noise.bands < image.bands
  image = Vips::Image.bandjoin([r, g, b]) + (noise * 0.2).cast("uchar")
  $logger.debug "Glitch applied, avg: #{image.avg}"
  image
end

# Adds neon glow
def neon_glow(image, intensity, mode, params = {})
  return image if image.bands == 0
  overlay = Vips::Image.black(image.width, image.height, bands: image.bands)
  count = mode == "professional" ? rand(2..3) : rand(3..5)
  $logger.debug "Applying #{count} neon glows"

  count.times do
    x, y = rand(image.width), rand(image.height)
    radius = image.width / rand(3..5)
    color = [rand([255, 0]) * intensity, rand(0..100) * intensity, rand([0, 255]) * intensity]
    overlay = overlay.draw_circle(color, x, y, radius, fill: true)
  end

  image = (image + overlay.gaussblur(intensity * 0.3) * 0.2).cast("uchar")
  $logger.debug "Neon glow applied, avg: #{image.avg}"
  image
end

# Simulates pixel sorting
def pixel_sorting(image, intensity, mode, params = {})
  return image if image.bands == 0
  strip_count = mode == "professional" ? rand(5..10) : rand(10..20)
  $logger.debug "Applying pixel sorting, strip_count: #{strip_count}"

  result = image.dup
  strip_height = image.height / strip_count
  strip_count.times do |i|
    y = i * strip_height
    strip = result.crop(0, y, image.width, [strip_height, image.height - y].min)
    pixels = strip.flatten
    sorted_pixels = pixels.sort
    sorted_strip = Vips::Image.new_from_array([sorted_pixels], strip.height, strip.width).cast("uchar")
    sorted_strip = sorted_strip.bandjoin([sorted_strip] * (image.bands - 1)) if image.bands > 1
    result = result.draw_image(sorted_strip, 0, y)
  end

  image = result
  $logger.debug "Pixel sorting applied, avg: #{image.avg}"
  image
end

# Mimics prismatic splitting
def lens_prism(image, intensity, mode, params = {})
  return image if image.bands == 0
  angle = mode == "professional" ? rand(5..10) * intensity : rand(10..15) * intensity
  $logger.debug "Applying lens prism, angle: #{angle}"

  r, g, b = image.bandsplit
  r = r.embed(angle.to_i, 0, image.width, image.height, extend: "mirror").crop(0, 0, image.width, image.height)
  b = b.embed(-angle.to_i, 0, image.width, image.height, extend: "mirror").crop(0, 0, image.width, image.height)
  image = Vips::Image.bandjoin([r, g, b]).cast("uchar")
  $logger.debug "Lens prism applied, avg: #{image.avg}"
  image
end

# Adds TV static noise
def static_noise(image, intensity, mode, params = {})
  return image if image.bands == 0
  sigma = mode == "professional" ? rand(20..30) * intensity : rand(30..50) * intensity
  $logger.debug "Applying static noise, sigma: #{sigma}"

  noise = get_shared_noise(image.width, image.height, rand(10..20))
  noise = noise.linear([sigma], [0])
  noise = noise.bandjoin([noise] * (image.bands - 1)) if noise.bands < image.bands
  image = (image + noise * 0.3).cast("uchar")
  $logger.debug "Static noise applied, avg: #{image.avg}"
  image
end

# Simulates emulsion layering
def emulsion_layering(image, intensity, mode, params = {})
  return image if image.bands == 0
  layers = mode == "professional" ? rand(2..3) : rand(3..5)
  $logger.debug "Applying emulsion layering, layers: #{layers}"

  result = image
  noise_base = get_shared_noise(image.width, image.height, rand(10..30))
  noise_base = noise_base.bandjoin([noise_base] * (image.bands - 1)) if noise_base.bands < image.bands
  layers.times do
    noise = noise_base.linear([intensity * 0.5], [0])
    result = (result + noise * rand(0.03..0.08)).cast("uchar")
  end
  $logger.debug "Emulsion layering applied, avg: #{result.avg}"
  result
end

# Applies temporal wear patterns
def temporal_wear(image, intensity, mode, params = {})
  return image if image.bands == 0
  age = params["age"] || %w[recent aged ancient].sample
  count = case age
          when "recent" then rand(2..4)
          when "aged" then rand(4..6)
          else rand(6..8)
          end
  $logger.debug "Applying temporal wear, age: #{age}, count: #{count}"

  wear = Vips::Image.black(image.width, image.height, bands: image.bands)
  count.times do
    if rand < 0.5
      x = rand(image.width)
      width = rand(1..3) * intensity
      wear = wear.draw_rect([rand(200..255) * intensity] * image.bands, x, 0, width, image.height, fill: true)
    else
      x, y = rand(image.width), rand(image.height)
      radius = image.width / rand(4..6)
      color = [rand(100..150) * intensity, rand(80..120) * intensity, rand(50..100) * intensity]
      wear = wear.draw_circle(color, x, y, radius, fill: true)
    end
  end

  image = (image + wear.gaussblur(intensity * 0.2) * 0.1).cast("uchar")
  $logger.debug "Temporal wear applied, avg: #{image.avg}"
  image
end

# Applies spectral color drift
def spectral_color_drift(image, intensity, mode, params = {})
  return image if image.bands == 0
  r, g, b = image.bandsplit
  shifts = mode == "professional" ? [rand(-0.1..0.1), rand(-0.1..0.1), rand(-0.1..0.1)] : [rand(-0.2..0.2), rand(-0.2..0.2), rand(-0.2..0.2)]
  $logger.debug "Applying spectral color drift, shifts: #{shifts}"

  r = r.linear([1 + shifts[0] * intensity], [rand(-5..5) * intensity])
  g = g.linear([1 + shifts[1] * intensity], [rand(-5..5) * intensity])
  b = b.linear([1 + shifts[2] * intensity], [rand(-5..5) * intensity])
  image = Vips::Image.bandjoin([r, g, b]).cast("uchar")
  $logger.debug "Spectral color drift applied, avg: #{image.avg}"
  image
end

# Processes file with variants
# @param file [String] Input file path
# @param variations [Integer] Number of variants
# @param recipe [Hash, nil] JSON recipe
# @param apply_random [Boolean] Apply random effects
# @param effect_count [Integer] Number of effects per variant
# @param mode [String] Processing mode
# @param save_recipe [Boolean] Save recipe
# @param optimize_web [Boolean] Optimize for web
# @return [Integer] Number of processed variants
def process_file(file, variations, recipe, apply_random, effect_count, mode, save_recipe, optimize_web)
  $logger.debug "Processing '#{file}': #{variations} variants, #{effect_count} effects, mode: #{mode}, optimize_web: #{optimize_web}"
  image = load_image(file)
  unless image
    $logger.error "Skipping '#{file}': failed to load"
    return 0
  end

  $logger.debug "Memory usage: #{ObjectSpace.memsize_of_all / 1024} KB"
  original_avg = image.avg
  processed_count = 0
  recipe_data = { file: file, variants: [] }

  variations.times do |i|
    $logger.debug "Starting variant #{i + 1} for '#{file}'"
    variant_effects = []
    processed_image = if recipe
                       result = apply_effects_from_recipe(image, recipe, mode)
                       variant_effects = result[:applied_effects]
                       result[:image]
                     elsif apply_random
                       variation_effects = random_effects(effect_count, mode, file)
                       result = apply_effects(image, variation_effects, mode)
                       variant_effects = result[:applied_effects]
                       result[:image]
                     else
                       $cli_logger.warn "No effects selected, skipping variant #{i + 1}"
                       next
                     end

    unless processed_image
      $logger.error "Variant #{i + 1} failed: nil image"
      next
    end

    polish_intensity = random_intensity(mode)
    processed_image = film_stock_emulation(processed_image, polish_intensity, mode)
    variant_effects << { effect: "film_stock_emulation", intensity: polish_intensity.round(2) }

    polish_intensity = random_intensity(mode)
    processed_image = film_grain(processed_image, polish_intensity, mode)
    variant_effects << { effect: "film_grain", intensity: polish_intensity.round(2) }

    polish_intensity = random_intensity(mode)
    processed_image = film_scratches(processed_image, polish_intensity, mode)
    variant_effects << { effect: "film_scratches", intensity: polish_intensity.round(2) }

    processed_image = processed_image.extract_band(0, n: 3) if processed_image.bands > 3

    if optimize_web
      $logger.debug "Applying web optimization"
      processed_image = processed_image.maplut(WEB_PALETTE)
    end

    final_avg = processed_image.avg
    change = (final_avg - original_avg).round(2)
    $logger.debug "Variant #{i + 1} complete, avg: #{final_avg}, change: #{change}"

    timestamp = Time.now.strftime("%Y%m%d%H%M%S")
    unique_id = SecureRandom.hex(2)
    output_file = file.sub(File.extname(file), "_processed_v#{i + 1}_#{timestamp}_#{unique_id}#{File.extname(file)}")
    if File.exist?(output_file)
      $logger.warn "Output '#{output_file}' exists, skipping variant #{i + 1}"
      next
    end

    processed_image.write_to_file(output_file)
    $cli_logger.info "Saved variant #{i + 1} as #{output_file}, avg: #{final_avg}, change: #{change}"
    processed_count += 1
    recipe_data[:variants] << { variant: i + 1, effects: variant_effects }
  end

  if save_recipe && !recipe_data[:variants].empty?
    recipe_file = "recipe_#{timestamp}_#{SecureRandom.hex(2)}.json"
    File.write(recipe_file, JSON.pretty_generate(recipe_data))
    $cli_logger.info "Saved recipe to '#{recipe_file}'"
  end

  SHARED_NOISE.clear
  $logger.debug "Cleared SHARED_NOISE, memory usage: #{ObjectSpace.memsize_of_all / 1024} KB"
  processed_count
rescue StandardError => e
  $logger.error "Processing '#{file}' failed: #{e.message}"
  processed_count || 0
end

# Expands brace patterns
def expand_pattern(pattern)
  return [pattern] if pattern.empty? || !pattern.match?(/\{.*\}/) || pattern.match?(/^\.\.\//)

  $logger.warn "Suspicious pattern: #{pattern}" if pattern.match?(/^\.\.\//)
  extensions = pattern.match(/\{(.*)\}/)&.[](1)&.split(",")&.map(&:strip)&.reject(&:empty?) || []
  extensions.map { |ext| pattern.sub(/\{.*\}/, ext) }
rescue StandardError => e
  $logger.error "Pattern expansion failed: #{e.message}"
  [pattern]
end

# Collects CLI inputs
def get_input
  $logger.debug "Starting input collection"
  $cli_logger.info "Postpro.rb v13.4.27 - Vintage and cinematic effects"

  mode = PROMPT.yes?("Professional mode? (analog focus)", default: true) ? "professional" : "experimental"
  apply_random = PROMPT.yes?("Random effects? (else custom recipe)", default: true)
  recipe_file = PROMPT.ask("JSON recipe file (Enter for none):", default: "").strip
  patterns = PROMPT.ask("File patterns (e.g., **/*.{jpg,png}):", default: "**/*.{jpg,jpeg,png,webp}").strip
  file_patterns = patterns.split(",").flat_map { |p| expand_pattern(p.strip) }
  variations = PROMPT.ask("Variations per image (1-5):", convert: :int, default: 3) { |q| q.in("1-5") }
  effect_count = if apply_random
                   PROMPT.ask("Effects per variant (#{mode == "experimental" ? "5-8" : "3-5"}):",
                              convert: :int,
                              default: mode == "experimental" ? 6 : 4) { |q| q.in(mode == "experimental" ? "5-8" : "3-5") }
                 else
                   0
                 end
  save_recipe = PROMPT.yes?("Save recipe? (JSON)", default: false)
  optimize_web = PROMPT.yes?("Optimize for web? (256-color palette)", default: false)

  recipe = if recipe_file.empty?
             nil
           elsif File.exist?(recipe_file)
             JSON.parse(File.read(recipe_file))
           else
             $cli_logger.error "Recipe '#{recipe_file}' not found"
             nil
           end
  $cli_logger.info "Loaded recipe from '#{recipe_file}'" if recipe

  [file_patterns, variations, recipe, apply_random, effect_count, mode, save_recipe, optimize_web]
rescue JSON::ParserError => e
  $cli_logger.error "Invalid JSON recipe '#{recipe_file}': #{e.message}"
  nil
rescue StandardError => e
  $cli_logger.error "Input failed: #{e.message}"
  nil
end

# Main execution loop
def main
  $logger.debug "Starting Postpro.rb v13.4.27"
  inputs = get_input
  unless inputs
    $cli_logger.error "Failed to gather input, exiting"
    exit 1
  end

  file_patterns, variations, recipe, apply_random, effect_count, mode, save_recipe, optimize_web = inputs
  files = file_patterns.flat_map { |p| Dir.glob(p, File::FNM_CASEFOLD | File::FNM_DOTMATCH) }
                       .uniq
                       .reject { |f| f.match?(/processed_v\d+_\d+/) }

  if files.empty?
    $cli_logger.error "No files matched: #{file_patterns.join(", ")}"
    exit 1
  end

  $cli_logger.info "Processing #{files.size} file#{files.size == 1 ? "" : "s"}..."
  total_variations = successful_files = 0
  retries = {}

  files.each do |file|
    retries[file] ||= 0
    variation_count = process_file(file, variations, recipe, apply_random, effect_count, mode, save_recipe, optimize_web)
    total_variations += variation_count
    successful_files += 1 if variation_count > 0
  rescue StandardError => e
    $logger.error "Error processing '#{file}': #{e.message}"
    if retries[file] < 2
      retries[file] += 1
      $cli_logger.warn "Retrying '#{file}' (attempt #{retries[file] + 1}/2)"
      retry
    else
      $cli_logger.error "Failed '#{file}' after 2 retries: #{e.message}"
    end
  end

  $cli_logger.info "Completed: #{successful_files} file#{successful_files == 1 ? "" : "s"} processed, #{total_variations} variation#{total_variations == 1 ? "" : "s"} created"
  exit 0
rescue StandardError => e
  $logger.error "Unexpected failure: #{e.message}"
  exit 1
end

main if $0 == __FILE__
# EOF (540 lines)
# CHECKSUM: sha256:placeholder_hash