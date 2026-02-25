#!/bin/bash

# OpenAI Provider - AI module generation using OpenAI API

# Configuration
readonly API_BASE="${CONFIG_AI_API_BASE:-https://api.openai.com/v1}"
readonly MODEL="${CONFIG_AI_MODEL:-gpt-3.5-turbo}"
readonly MAX_TOKENS=4000
readonly TEMPERATURE=0.3

# Generate content using OpenAI API
ai_generate_content() {
    local prompt="$1"

    if [[ -z "${CONFIG_AI_API_KEY}" ]]; then
        echo "ERROR: OpenAI API key not configured" >&2
        return 1
    fi

    # Prepare API payload
    local payload
    payload=$(jq -n \
        --arg model "${MODEL}" \
        --arg prompt "${prompt}" \
        --argjson max_tokens "${MAX_TOKENS}" \
        --argjson temperature "${TEMPERATURE}" \
        '{
            model: $model,
            messages: [
                {
                    role: "system",
                    content: "You are a DevOps expert creating Bash modules for the DevMachine CLI tool. Generate production-quality, secure, and idempotent Bash code. Each module must implement install(), remove(), and status() functions. Use proper error handling, logging, and safety checks."
                },
                {
                    role: "user",
                    content: $prompt
                }
            ],
            max_tokens: $max_tokens,
            temperature: $temperature
        }')

    # Make API request
    local response
    if ! response=$(curl -s \
        -X POST \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${CONFIG_AI_API_KEY}" \
        -d "${payload}" \
        "${API_BASE}/chat/completions"); then
        echo "ERROR: Failed to connect to OpenAI API" >&2
        return 1
    fi

    # Extract content from response
    local content
    content=$(echo "${response}" | jq -r '.choices[0].message.content // empty')

    if [[ -z "${content}" ]]; then
        echo "ERROR: No content received from OpenAI API" >&2
        echo "Response: ${response}" >&2
        return 1
    fi

    # Remove markdown code blocks if present
    content=$(echo "${content}" | sed 's/^```bash$//' | sed 's/^```$//' | sed 's/^`$//')

    echo "${content}"
}

# Provider info
provider_info() {
    echo "OpenAI Provider"
    echo "API Base: ${API_BASE}"
    echo "Model: ${MODEL}"
    echo "Max Tokens: ${MAX_TOKENS}"
    echo "Temperature: ${TEMPERATURE}"
}

# Test provider connection
test_connection() {
    if [[ -z "${CONFIG_AI_API_KEY}" ]]; then
        echo "ERROR: API key not configured"
        return 1
    fi

    # Simple test request
    local test_payload
    test_payload=$(jq -n '{model: "gpt-3.5-turbo", messages: [{role: "user", content: "test"}], max_tokens: 1}')

    if curl -s \
        -X POST \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${CONFIG_AI_API_KEY}" \
        -d "${test_payload}" \
        "${API_BASE}/chat/completions" > /dev/null; then
        echo "Connection test: SUCCESS"
        return 0
    else
        echo "Connection test: FAILED"
        return 1
    fi
}

# Entry point for testing
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "OpenAI Provider for DevMachine"
    echo ""

    case "${1:-}" in
        info)
            provider_info
            ;;
        test)
            test_connection
            ;;
        *)
            echo "Usage: ${0} {info|test}"
            echo ""
            echo "  info    - Show provider configuration"
            echo "  test    - Test API connection"
            ;;
    esac
fi