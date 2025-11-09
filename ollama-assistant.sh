#!/bin/bash

# ============================================
# Ollama Project Assistant - v1.0
# Drop-in AI coding assistant for any project
# ============================================

set -e

# --- CONFIGURATION SECTION ---
DEFAULT_OLLAMA_SERVER="http://localhost:11434"
DEFAULT_MODEL="llama3.2"
DEFAULT_THEME="dark"
AUTO_SAVE=true
GIT_INTEGRATION=true
MAX_HISTORY=50

# --- COLOR SCHEMES ---
setup_colors() {
    if [[ "$THEME" == "light" ]]; then
        COLOR_RESET='\033[0m'
        COLOR_BOLD='\033[1m'
        COLOR_DIM='\033[2m'
        
        # Colors
        COLOR_BLACK='\033[30m'
        COLOR_RED='\033[31m'
        COLOR_GREEN='\033[32m'
        COLOR_YELLOW='\033[33m'
        COLOR_BLUE='\033[34m'
        COLOR_MAGENTA='\033[35m'
        COLOR_CYAN='\033[36m'
        COLOR_WHITE='\033[37m'
        
        # Background colors
        BG_BLACK='\033[40m'
        BG_RED='\033[41m'
        BG_GREEN='\033[42m'
        BG_YELLOW='\033[43m'
        BG_BLUE='\033[44m'
        BG_MAGENTA='\033[45m'
        BG_CYAN='\033[46m'
        BG_WHITE='\033[47m'
    else
        COLOR_RESET='\033[0m'
        COLOR_BOLD='\033[1m'
        COLOR_DIM='\033[2m'
        
        # Colors (dark theme variants)
        COLOR_BLACK='\033[90m'
        COLOR_RED='\033[91m'
        COLOR_GREEN='\033[92m'
        COLOR_YELLOW='\033[93m'
        COLOR_BLUE='\033[94m'
        COLOR_MAGENTA='\033[95m'
        COLOR_CYAN='\033[96m'
        COLOR_WHITE='\033[97m'
        
        # Background colors
        BG_BLACK='\033[100m'
        BG_RED='\033[101m'
        BG_GREEN='\033[102m'
        BG_YELLOW='\033[103m'
        BG_BLUE='\033[104m'
        BG_MAGENTA='\033[105m'
        BG_CYAN='\033[106m'
        BG_WHITE='\033[107m'
    fi
}

# --- GLOBAL VARIABLES ---
OLLAMA_SERVER="$DEFAULT_OLLAMA_SERVER"
MODEL="$DEFAULT_MODEL"
THEME="$DEFAULT_THEME"
CURRENT_PROJECT=""
PROJECT_TYPE=""
PROJECT_FILES=()
CONVERSATION_HISTORY=()
TOKEN_COUNT=0
SESSION_START=$(date +%s)
STREAM_PID=""
CHAT_FILE=".ollama/history.txt"
CONFIG_FILE=".ollama/config.txt"
PROJECT_CACHE_FILE=".ollama/cache/project_context.txt"

# --- UTILITY FUNCTIONS ---
setup_directories() {
    mkdir -p .ollama/{history,cache}
}

load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        while IFS='=' read -r key value; do
            case "$key" in
                OLLAMA_SERVER) OLLAMA_SERVER="$value" ;;
                MODEL) MODEL="$value" ;;
                THEME) THEME="$value" ;;
                AUTO_SAVE) AUTO_SAVE="$value" ;;
                GIT_INTEGRATION) GIT_INTEGRATION="$value" ;;
            esac
        done < "$CONFIG_FILE"
    fi
}

save_config() {
    cat > "$CONFIG_FILE" << EOF
OLLAMA_SERVER=$OLLAMA_SERVER
MODEL=$MODEL
THEME=$THEME
AUTO_SAVE=$AUTO_SAVE
GIT_INTEGRATION=$GIT_INTEGRATION
EOF
}

detect_project_type() {
    if [[ -f "package.json" ]]; then
        echo "nodejs"
    elif [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]] || [[ -f "setup.py" ]]; then
        echo "python"
    elif [[ -f "Cargo.toml" ]]; then
        echo "rust"
    elif [[ -f "go.mod" ]]; then
        echo "go"
    elif [[ -f "composer.json" ]]; then
        echo "php"
    elif [[ -f "Gemfile" ]]; then
        echo "ruby"
    elif [[ -f "pom.xml" ]] || [[ -f "build.gradle" ]]; then
        echo "java"
    elif [[ -f "CMakeLists.txt" ]] || [[ -f "Makefile" ]]; then
        echo "cpp"
    else
        echo "general"
    fi
}

scan_project_files() {
    PROJECT_FILES=()
    local key_patterns=("*.js" "*.ts" "*.py" "*.rs" "*.go" "*.java" "*.cpp" "*.c" "*.h" "*.hpp" "*.json" "*.yaml" "*.yml" "*.toml" "*.md" "*.txt" "*.html" "*.css")
    
    for pattern in "${key_patterns[@]}"; do
        while IFS= read -r -d '' file; do
            PROJECT_FILES+=("$file")
        done < <(find . -name "$pattern" -not -path "./.ollama/*" -not -path "./node_modules/*" -not -path "./target/*" -not -path "./.git/*" -print0 2>/dev/null)
    done
}

get_git_status() {
    if [[ "$GIT_INTEGRATION" == "true" ]] && command -v git >/dev/null 2>&1 && [[ -d ".git" ]]; then
        local status=$(git status --porcelain 2>/dev/null | wc -l)
        local branch=$(git branch --show-current 2>/dev/null || echo "unknown")
        if [[ "$status" -eq 0 ]]; then
            echo "clean, branch: $branch"
        else
            echo "$status modified, branch: $branch"
        fi
    else
        echo "git not available"
    fi
}

get_last_modified() {
    local latest_file=""
    local latest_time=0
    
    for file in "${PROJECT_FILES[@]}"; do
        if [[ -f "$file" ]]; then
            local file_time=$(stat -c %Y "$file" 2>/dev/null || stat -f %m "$file" 2>/dev/null)
            if [[ "$file_time" -gt "$latest_time" ]]; then
                latest_time="$file_time"
                latest_file="$file"
            fi
        fi
    done
    
    if [[ -n "$latest_file" ]]; then
        local time_diff=$((SESSION_START - latest_time))
        if [[ "$time_diff" -lt 3600 ]]; then
            echo "${latest_file} ($((time_diff / 60))m ago)"
        elif [[ "$time_diff" -lt 86400 ]]; then
            echo "${latest_file} ($((time_diff / 3600))h ago)"
        else
            echo "${latest_file} ($(date -d "@$latest_time" '+%Y-%m-%d'))"
        fi
    else
        echo "No files found"
    fi
}

# --- UI COMPONENTS ---
clear_screen() {
    clear
    tput cup 0 0 2>/dev/null || true
}

draw_box() {
    local width=$1
    local height=$2
    local title=$3
    
    echo -n "┌─"
    printf "%*s" $((width - 4)) | tr ' ' '─'
    echo "─┐"
    
    if [[ -n "$title" ]]; then
        local title_len=${#title}
        local padding=$((width - title_len - 6))
        echo "│ ${COLOR_BOLD}$title${COLOR_RESET}$(printf "%*s" $padding)│"
        echo "├─$(printf "%*s" $((width - 4)) | tr ' ' '─')─┤"
    fi
    
    for ((i=3; i<height; i++)); do
        echo "│$(printf "%*s" $((width - 2)))│"
    done
    
    echo -n "└─"
    printf "%*s" $((width - 4)) | tr ' ' '─'
    echo "─┘"
}

draw_header() {
    local term_width=$(tput cols 2>/dev/null || echo 80)
    local project_name=$(basename "$(pwd)")
    local git_status=$(get_git_status)
    local connection_status="🟢 Connected"
    
    # Test connection
    if ! curl -s --connect-timeout 2 "$OLLAMA_SERVER/api/tags" >/dev/null 2>&1; then
        connection_status="🔴 Disconnected"
    fi
    
    echo -e "${COLOR_CYAN}┌─ Ollama Project Assistant v1.0 ${COLOR_RESET}$(printf "%*s" $((term_width - 35)) )┐"
    echo -e "│ 📁 $project_name │ 🤖 $MODEL │ $connection_status │ 💾 $TOKEN_COUNT tokens │$(printf "%*s" $((term_width - ${#project_name} - ${#MODEL} - ${#connection_status} - ${#TOKEN_COUNT} - 50)))│"
    echo -e "├─ Project Context $(printf "%*s" $((term_width / 2 - 20)) | tr ' ' '─') Chat $(printf "%*s" $((term_width / 2 - 10)) | tr ' ' '─')─┤"
}

draw_project_context() {
    local term_width=$(tput cols 2>/dev/null || echo 80)
    local context_width=$((term_width / 2 - 3))
    local last_modified=$(get_last_modified)
    
    echo -e "│ ${COLOR_BOLD}🏷️  $PROJECT_TYPE Project${COLOR_RESET}$(printf "%*s" $((context_width - ${#PROJECT_TYPE} - 15))) │"
    
    # Show key files
    local key_files=""
    local count=0
    for file in "${PROJECT_FILES[@]:0:3}"; do
        if [[ $count -gt 0 ]]; then key_files+=", "; fi
        key_files+=$(basename "$file")
        ((count++))
    done
    if [[ ${#PROJECT_FILES[@]} -gt 3 ]]; then
        key_files+=", ..."
    fi
    
    echo -e "│ 📋 $key_files$(printf "%*s" $((context_width - ${#key_files} - 5))) │"
    echo -e "│ 📊 ${#PROJECT_FILES[@]} files, $(count_lines) LOC$(printf "%*s" $((context_width - 25))) │"
    echo -e "│ 🌿 Git: $(get_git_status)$(printf "%*s" $((context_width - 25))) │"
    echo -e "│ 📅 Last modified: $last_modified$(printf "%*s" $((context_width - ${#last_modified} - 20))) │"
    echo -e "│                                               │"
    echo -e "│ ${COLOR_DIM}Quick Actions:${COLOR_RESET}                           │"
    echo -e "│ [F1]Help [F2]Files [F3]Git [F4]Config         │"
}

count_lines() {
    local total=0
    for file in "${PROJECT_FILES[@]}"; do
        if [[ -f "$file" ]]; then
            local lines=$(wc -l < "$file" 2>/dev/null || echo 0)
            total=$((total + lines))
        fi
    done
    echo "$total"
}

draw_chat_area() {
    local term_width=$(tput cols 2>/dev/null || echo 80)
    local chat_width=$((term_width / 2))
    local chat_height=$((LINES - 12))
    
    echo -e "│$(printf "%*s" $chat_width)│"
    
    # Show last few messages from conversation history
    local start_idx=0
    if [[ ${#CONVERSATION_HISTORY[@]} -gt $chat_height ]]; then
        start_idx=$((${#CONVERSATION_HISTORY[@]} - chat_height))
    fi
    
    for ((i=start_idx; i<${#CONVERSATION_HISTORY[@]}; i++)); do
        local msg="${CONVERSATION_HISTORY[$i]}"
        local truncated_msg="${msg:0:$((chat_width - 4))}"
        echo -e "│ $truncated_msg$(printf "%*s" $((chat_width - ${#truncated_msg} - 2)))│"
    done
}

draw_input_prompt() {
    local term_width=$(tput cols 2>/dev/null || echo 80)
    echo -e "├─$(printf "%*s" $((term_width - 4)) | tr ' ' '─')─┤"
    echo -e "│${COLOR_GREEN}>${COLOR_RESET} Type your question or command (/help for commands)$(printf "%*s" $((term_width - 60)))│"
    echo -e "└─$(printf "%*s" $((term_width - 4)) | tr ' ' '─')─┘"
}

refresh_display() {
    clear_screen
    draw_header
    draw_project_context
    draw_chat_area
    draw_input_prompt
}

# --- API FUNCTIONS ---
test_connection() {
    if curl -s --connect-timeout 3 "$OLLAMA_SERVER/api/tags" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

get_available_models() {
    if test_connection; then
        curl -s "$OLLAMA_SERVER/api/tags" | grep -o '"name":"[^"]*"' | cut -d'"' -f4
    else
        echo "Error: Cannot connect to Ollama server at $OLLAMA_SERVER"
        return 1
    fi
}

send_message_to_ollama() {
    local message="$1"
    local temp_file=$(mktemp)
    
    # Build conversation context
    local context="{\"model\":\"$MODEL\",\"messages\":["
    
    # Add system message with project context
    context+="{\"role\":\"system\",\"content\":\"You are helping with a $PROJECT_TYPE project in $(basename \"$(pwd)\"). Current directory: $(pwd). Key files: $(IFS=', '; echo \"${PROJECT_FILES[*]:0:5}\"). Git status: $(get_git_status).\"},"
    
    # Add conversation history
    for msg in "${CONVERSATION_HISTORY[@]: -$MAX_HISTORY}"; do
        if [[ "$msg" =~ ^🧑\  ]]; then
            local content="${msg#🧑  }"
            context+="{\"role\":\"user\",\"content\":\"$content\"},"
        elif [[ "$msg" =~ ^🤖\  ]]; then
            local content="${msg#🤖  }"
            context+="{\"role\":\"assistant\",\"content\":\"$content\"},"
        fi
    done
    
    # Add current message
    context+="{\"role\":\"user\",\"content\":\"$message\"}],\"stream\":true}"
    
    # Send request and process stream
    curl -s -X POST "$OLLAMA_SERVER/api/chat" \
        -H "Content-Type: application/json" \
        -d "$context" | while read -r line; do
        if [[ -n "$line" ]]; then
            local content=$(echo "$line" | grep -o '"content":"[^"]*"' | cut -d'"' -f4 | sed 's/\\n/\n/g')
            if [[ -n "$content" ]]; then
                echo -n "$content"
                echo "$content" >> "$temp_file"
                ((TOKEN_COUNT++))
            fi
            
            local done=$(echo "$line" | grep -o '"done":true')
            if [[ -n "$done" ]]; then
                echo "" >> "$temp_file"
                local full_response=$(cat "$temp_file")
                add_to_chat_history "🤖  $full_response"
                rm -f "$temp_file"
                break
            fi
        fi
    done
}

# --- FILE OPERATIONS ---
read_file() {
    local file_path="$1"
    if [[ -f "$file_path" ]]; then
        echo -e "${COLOR_CYAN}--- $file_path ---${COLOR_RESET}"
        cat "$file_path"
        echo -e "${COLOR_CYAN}--- End of $file_path ---${COLOR_RESET}"
    else
        echo -e "${COLOR_RED}Error: File '$file_path' not found${COLOR_RESET}"
    fi
}

edit_file() {
    local file_path="$1"
    if [[ -f "$file_path" ]]; then
        # Create backup
        cp "$file_path" "${file_path}.backup.$(date +%s)"
        
        # Ask user for edit instructions
        echo -e "${COLOR_YELLOW}Current content of $file_path:${COLOR_RESET}"
        cat "$file_path"
        echo ""
        echo -e "${COLOR_GREEN}What changes would you like to make to $file_path?${COLOR_RESET}"
        read -r edit_instructions
        
        add_to_chat_history "🧑  Edit $file_path: $edit_instructions"
        
        # Get AI assistance for editing
        local ai_prompt="Please help me edit the file $file_path. Current content:\n$(cat "$file_path")\n\nUser request: $edit_instructions\n\nPlease provide the complete updated file content:"
        
        echo -e "${COLOR_CYAN}🤖  Getting AI assistance for editing...${COLOR_RESET}"
        local ai_response=$(echo -e "$ai_prompt" | send_message_to_ollama)
        
        # Apply the changes (this is simplified - in practice you'd want better parsing)
        echo "$ai_response" > "$file_path"
        
        echo -e "${COLOR_GREEN}✓ File $file_path has been updated${COLOR_RESET}"
        echo -e "${COLOR_DIM}Backup saved as ${file_path}.backup.$(date +%s)${COLOR_RESET}"
    else
        echo -e "${COLOR_RED}Error: File '$file_path' not found${COLOR_RESET}"
    fi
}

list_files() {
    local pattern="${1:-*}"
    echo -e "${COLOR_CYAN}Files matching '$pattern':${COLOR_RESET}"
    find . -name "$pattern" -not -path "./.ollama/*" -not -path "./node_modules/*" -not -path "./target/*" -not -path "./.git/*" | head -20
}

run_git_command() {
    if [[ "$GIT_INTEGRATION" == "true" ]] && command -v git >/dev/null 2>&1; then
        if [[ -d ".git" ]]; then
            echo -e "${COLOR_CYAN}Git command: git $@${COLOR_RESET}"
            git "$@"
        else
            echo -e "${COLOR_RED}Error: Not a git repository${COLOR_RESET}"
        fi
    else
        echo -e "${COLOR_RED}Error: Git integration is disabled or git is not installed${COLOR_RESET}"
    fi
}

# --- CHAT MANAGEMENT ---
add_to_chat_history() {
    local message="$1"
    CONVERSATION_HISTORY+=("$message")
    
    # Save to file if auto-save is enabled
    if [[ "$AUTO_SAVE" == "true" ]]; then
        echo "$message" >> "$CHAT_FILE"
    fi
}

load_chat_history() {
    if [[ -f "$CHAT_FILE" ]]; then
        while IFS= read -r line; do
            CONVERSATION_HISTORY+=("$line")
        done < "$CHAT_FILE"
    fi
}

clear_chat_history() {
    CONVERSATION_HISTORY=()
    > "$CHAT_FILE"
    echo -e "${COLOR_GREEN}✓ Chat history cleared${COLOR_RESET}"
}

save_chat() {
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local save_file=".ollama/chat_backup_$timestamp.txt"
    
    {
        echo "# Chat History Backup - $(date)"
        echo "# Project: $(basename "$(pwd)")"
        echo "# Model: $MODEL"
        echo "# Server: $OLLAMA_SERVER"
        echo ""
        for msg in "${CONVERSATION_HISTORY[@]}"; do
            echo "$msg"
        done
    } > "$save_file"
    
    echo -e "${COLOR_GREEN}✓ Chat saved to $save_file${COLOR_RESET}"
}

load_chat() {
    echo -e "${COLOR_CYAN}Available chat backups:${COLOR_RESET}"
    ls -la .ollama/chat_backup_*.txt 2>/dev/null || echo "No backups found"
    echo -e "${COLOR_YELLOW}Enter backup filename to load (or press Enter to cancel):${COLOR_RESET}"
    read -r backup_file
    
    if [[ -n "$backup_file" && -f "$backup_file" ]]; then
        CONVERSATION_HISTORY=()
        while IFS= read -r line; do
            if [[ ! "$line" =~ ^# ]]; then
                CONVERSATION_HISTORY+=("$line")
            fi
        done < "$backup_file"
        echo -e "${COLOR_GREEN}✓ Chat loaded from $backup_file${COLOR_RESET}"
    fi
}

# --- COMMAND HANDLING ---
handle_command() {
    local cmd="$1"
    local args="${cmd#* }"
    local base_cmd="${cmd%% *}"
    
    case "$base_cmd" in
        "/help")
            show_help
            ;;
        "/files")
            list_files "$args"
            ;;
        "/read")
            if [[ -n "$args" ]]; then
                read_file "$args"
            else
                echo -e "${COLOR_RED}Error: Please specify a file to read${COLOR_RESET}"
            fi
            ;;
        "/edit")
            if [[ -n "$args" ]]; then
                edit_file "$args"
            else
                echo -e "${COLOR_RED}Error: Please specify a file to edit${COLOR_RESET}"
            fi
            ;;
        "/git")
            if [[ -n "$args" ]]; then
                run_git_command $args
            else
                echo -e "${COLOR_RED}Error: Please specify a git command${COLOR_RESET}"
            fi
            ;;
        "/clear")
            clear_chat_history
            ;;
        "/save")
            save_chat
            ;;
        "/load")
            load_chat
            ;;
        "/config")
            show_config_menu
            ;;
        "/exit"|"/quit")
            echo -e "${COLOR_GREEN}Goodbye!${COLOR_RESET}"
            exit 0
            ;;
        *)
            echo -e "${COLOR_RED}Unknown command: $base_cmd${COLOR_RESET}"
            echo -e "${COLOR_YELLOW}Type /help for available commands${COLOR_RESET}"
            ;;
    esac
}

show_help() {
    echo -e "${COLOR_BOLD}Ollama Project Assistant - Commands${COLOR_RESET}"
    echo -e "${COLOR_CYAN}Chat Commands:${COLOR_RESET}"
    echo "  /help              - Show this help message"
    echo "  /files [pattern]   - List project files"
    echo "  /read <file>       - Read a file"
    echo "  /edit <file>       - Edit a file with AI assistance"
    echo "  /git <command>     - Execute git command"
    echo -e "${COLOR_CYAN}Session Commands:${COLOR_RESET}"
    echo "  /clear             - Clear chat history"
    echo "  /save              - Save conversation"
    echo "  /load              - Load previous conversation"
    echo "  /config            - Configure settings"
    echo "  /exit, /quit       - Exit assistant"
    echo -e "${COLOR_CYAN}Shortcuts:${COLOR_RESET}"
    echo "  F1                 - Show help"
    echo "  F2                 - List files"
    echo "  F3                 - Git status"
    echo "  F4                 - Configuration"
    echo "  Tab                - Command completion"
    echo "  Up/Down arrows     - Navigate command history"
}

show_config_menu() {
    echo -e "${COLOR_BOLD}Configuration Menu${COLOR_RESET}"
    echo "1. Ollama Server: $OLLAMA_SERVER"
    echo "2. Model: $MODEL"
    echo "3. Theme: $THEME"
    echo "4. Auto-save: $AUTO_SAVE"
    echo "5. Git Integration: $GIT_INTEGRATION"
    echo "6. Back to chat"
    echo -e "${COLOR_YELLOW}Enter option number to change (or 6 to exit):${COLOR_RESET}"
    read -r option
    
    case "$option" in
        1)
            echo -e "${COLOR_CYAN}Current server: $OLLAMA_SERVER${COLOR_RESET}"
            echo -e "${COLOR_YELLOW}Enter new server URL:${COLOR_RESET}"
            read -r new_server
            if [[ -n "$new_server" ]]; then
                OLLAMA_SERVER="$new_server"
                save_config
                echo -e "${COLOR_GREEN}✓ Server updated${COLOR_RESET}"
            fi
            ;;
        2)
            echo -e "${COLOR_CYAN}Available models:${COLOR_RESET}"
            get_available_models
            echo -e "${COLOR_YELLOW}Enter model name:${COLOR_RESET}"
            read -r new_model
            if [[ -n "$new_model" ]]; then
                MODEL="$new_model"
                save_config
                echo -e "${COLOR_GREEN}✓ Model updated${COLOR_RESET}"
            fi
            ;;
        3)
            echo -e "${COLOR_YELLOW}Enter theme (light/dark):${COLOR_RESET}"
            read -r new_theme
            if [[ "$new_theme" == "light" || "$new_theme" == "dark" ]]; then
                THEME="$new_theme"
                setup_colors
                save_config
                echo -e "${COLOR_GREEN}✓ Theme updated${COLOR_RESET}"
            else
                echo -e "${COLOR_RED}Invalid theme. Use 'light' or 'dark'${COLOR_RESET}"
            fi
            ;;
        4)
            if [[ "$AUTO_SAVE" == "true" ]]; then
                AUTO_SAVE="false"
            else
                AUTO_SAVE="true"
            fi
            save_config
            echo -e "${COLOR_GREEN}✓ Auto-save: $AUTO_SAVE${COLOR_RESET}"
            ;;
        5)
            if [[ "$GIT_INTEGRATION" == "true" ]]; then
                GIT_INTEGRATION="false"
            else
                GIT_INTEGRATION="true"
            fi
            save_config
            echo -e "${COLOR_GREEN}✓ Git Integration: $GIT_INTEGRATION${COLOR_RESET}"
            ;;
        6|*)
            return
            ;;
    esac
}

# --- MAIN APPLICATION ---
initialize() {
    setup_directories
    load_config
    setup_colors
    
    CURRENT_PROJECT=$(basename "$(pwd)")
    PROJECT_TYPE=$(detect_project_type)
    scan_project_files
    load_chat_history
    
    # Show welcome message
    echo -e "${COLOR_BOLD}${COLOR_CYAN}🤖 Welcome to Ollama Project Assistant!${COLOR_RESET}"
    echo -e "${COLOR_DIM}Project: $CURRENT_PROJECT ($PROJECT_TYPE)${COLOR_RESET}"
    echo -e "${COLOR_DIM}Files found: ${#PROJECT_FILES[@]}${COLOR_RESET}"
    echo -e "${COLOR_DIM}Model: $MODEL | Server: $OLLAMA_SERVER${COLOR_RESET}"
    
    if ! test_connection; then
        echo -e "${COLOR_RED}⚠️  Warning: Cannot connect to Ollama server${COLOR_RESET}"
        echo -e "${COLOR_RED}   Please ensure Ollama is running at $OLLAMA_SERVER${COLOR_RESET}"
    fi
    
    echo ""
    echo -e "${COLOR_GREEN}Ready to help! Type your question or /help for commands${COLOR_RESET}"
    echo ""
}

main_loop() {
    while true; do
        refresh_display
        echo -n -e "${COLOR_GREEN}>${COLOR_RESET} "
        read -r user_input
        
        if [[ -z "$user_input" ]]; then
            continue
        fi
        
        # Check if it's a command
        if [[ "$user_input" =~ ^/ ]]; then
            handle_command "$user_input"
        else
            # Add user message to history
            add_to_chat_history "🧑  $user_input"
            
            # Send to Ollama and display response
            echo -e "${COLOR_CYAN}🤖  Thinking...${COLOR_RESET}"
            send_message_to_ollama "$user_input"
        fi
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

# --- ENTRY POINT ---
main() {
    # Check for required dependencies
    if ! command -v curl >/dev/null 2>&1; then
        echo -e "${COLOR_RED}Error: curl is required but not installed${COLOR_RESET}"
        echo "Please install curl and try again"
        exit 1
    fi
    
    # Check terminal capabilities
    if [[ -t 0 ]] && [[ -t 1 ]]; then
        # Interactive mode
        initialize
        main_loop
    else
        echo "Error: This script requires an interactive terminal"
        exit 1
    fi
}

# Handle Ctrl+C gracefully
trap 'echo -e "\n${COLOR_YELLOW}Use /exit to quit${COLOR_RESET}"; continue' INT

# Run main function
main "$@"
