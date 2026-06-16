#!/usr/bin/env ruby
# frozen_string_literal: true

# Generates a Postman v2.1 collection from the rswag-generated OpenAPI spec.
# Run after regenerating swagger:  ruby postman/generate_collection.rb
require "yaml"
require "json"

ROOT      = File.expand_path("..", __dir__)
SPEC      = YAML.load_file(File.join(ROOT, "swagger/v1/swagger.yaml"))
OUT_DIR   = File.join(ROOT, "postman")
SCHEMAS   = SPEC.dig("components", "schemas") || {}
BASE_URL  = SPEC.dig("servers", 0, "url") || "http://localhost:3000"
METHODS   = %w[get post put patch delete].freeze

# --- example body builder ------------------------------------------------------
def example_for(schema)
  return nil if schema.nil?
  return example_for(SCHEMAS[schema["$ref"].split("/").last]) if schema["$ref"]
  return schema["example"] if schema.key?("example")

  case schema["type"]
  when "object"
    (schema["properties"] || {}).each_with_object({}) { |(k, v), h| h[k] = example_for(v) }
  when "array"
    [ example_for(schema["items"]) ].compact
  when "integer", "number" then schema["enum"]&.first || 0
  when "boolean" then false
  else
    schema["enum"]&.first || (schema["format"] == "date-time" ? "2026-01-01T00:00:00Z" : "string")
  end
end

# --- url / param helpers -------------------------------------------------------
def path_segments(path)
  path.split("/").reject(&:empty?).map { |seg| seg.start_with?("{") ? ":#{seg[1..-2]}" : seg }
end

def path_variables(params)
  params.select { |p| p["in"] == "path" }.map do |p|
    name = p["name"]
    value = if name == "id" || name.end_with?("_id") then "1"
    elsif name == "slug" then "my-slug"
    else "example"
    end
    { "key" => name, "value" => value, "description" => p["description"].to_s }
  end
end

def query_params(params)
  params.select { |p| p["in"] == "query" }.map do |p|
    ex = p.dig("schema", "example")
    ex ||= (p.dig("schema", "type") == "integer" ? "1" : "")
    { "key" => p["name"], "value" => ex.to_s, "description" => p["description"].to_s, "disabled" => true }
  end
end

def multipart_field(path)
  return "thumbnail" if path.end_with?("/thumbnail")

  "file"
end

# --- request builder -----------------------------------------------------------
def build_request(path, method, op, shared_params)
  params  = (shared_params + (op["parameters"] || [])).uniq { |p| [ p["name"], p["in"] ] }
  headers = [ { "key" => "Accept", "value" => "application/json" } ]
  body    = nil

  content = op.dig("requestBody", "content") || {}
  if content["application/json"]
    headers.unshift("key" => "Content-Type", "value" => "application/json")
    raw = if path == "/api/v1/session" && method == "post"
      JSON.pretty_generate("session" => { "email" => "{{email}}", "password" => "{{password}}" })
    else
      JSON.pretty_generate(example_for(content.dig("application/json", "schema")))
    end
    body = { "mode" => "raw", "raw" => raw, "options" => { "raw" => { "language" => "json" } } }
  elsif content["multipart/form-data"]
    field = multipart_field(path)
    body  = { "mode" => "formdata",
              "formdata" => [ { "key" => field, "type" => "file", "src" => [], "description" => "#{field} to upload" } ] }
  end

  url = {
    "raw" => "{{baseUrl}}/#{path_segments(path).join('/')}",
    "host" => [ "{{baseUrl}}" ],
    "path" => path_segments(path)
  }
  q = query_params(params)
  url["query"] = q unless q.empty?
  v = path_variables(params)
  url["variable"] = v unless v.empty?

  request = {
    "method" => method.upcase,
    "header" => headers,
    "url" => url,
    "description" => op["description"].to_s
  }
  request["body"] = body if body

  { "name" => op["summary"] || "#{method.upcase} #{path}", "request" => request, "response" => [] }
end

# --- group into folders by tag, preserving a sensible order --------------------
folders = {}
order   = (SPEC["tags"] || []).map { |t| t["name"] }

SPEC["paths"].each do |path, item|
  shared = item["parameters"] || []
  METHODS.each do |method|
    op = item[method]
    next unless op

    tag = (op["tags"] || [ "Untagged" ]).first
    order << tag unless order.include?(tag)
    (folders[tag] ||= []) << build_request(path, method, op, shared)
  end
end

items = order.select { |t| folders[t] }.map { |tag| { "name" => tag, "item" => folders[tag] } }

collection = {
  "info" => {
    "name" => "#{SPEC.dig('info', 'title')} (#{SPEC.dig('info', 'version')})",
    "description" => "#{SPEC.dig('info', 'description')}\n\n" \
                     "Auth: cookie-based. Run **Public | Sessions → Create session (login)** first; " \
                     "Postman stores the httpOnly `session_token` cookie and sends it automatically on " \
                     "subsequent requests. Set `baseUrl`, `email`, and `password` in the environment.",
    "schema" => "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item" => items,
  "variable" => [
    { "key" => "baseUrl", "value" => BASE_URL },
    { "key" => "email",   "value" => "admin@example.com" },
    { "key" => "password", "value" => "Password12345!" }
  ]
}

File.write(File.join(OUT_DIR, "kondangyuk-api.postman_collection.json"), JSON.pretty_generate(collection) + "\n")

environment = {
  "name" => "Kondangyuk — Local",
  "values" => [
    { "key" => "baseUrl", "value" => BASE_URL, "enabled" => true },
    { "key" => "email", "value" => "admin@example.com", "enabled" => true },
    { "key" => "password", "value" => "Password12345!", "enabled" => true }
  ],
  "_postman_variable_scope" => "environment"
}
File.write(File.join(OUT_DIR, "kondangyuk-api.postman_environment.json"), JSON.pretty_generate(environment) + "\n")

puts "Generated #{items.sum { |f| f['item'].size }} requests across #{items.size} folders."
