#!/bin/bash

# configuration
readonly DATA_DIR="./data"
readonly TASK_FILE="./data/tasks.csv"
readonly TASK_BACKUP_FILE="./data/tasks.gz"
readonly LOG_FILE="./data/task_manager.log"

# Color codes for better UI
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# ==================== UTILITY FUNCTIONS ====================

# Ensure that the directory and files exist
function intialize_task_file(){
    if ! validate_path "$TASK_FILE"; then

        # Create data directory if it doesn't exist
        if [[ ! -d $DATA_DIR ]]; then
            mkdir -p $DATA_DIR
            log_info "Created data directory"
        fi

        # Create tasks file if it doesn't exist
        if [[ ! -f "$TASK_FILE" ]]; then
            echo "ID,Description,Category,Priority,DueDate,Status,CreatedAt,UpdatedAt,CompletedAt" > "$TASK_FILE"
            log_info "Created tasks file with headers"
        fi

        # Create log file if it doesn't exist
        if [[ ! -f "$LOG_FILE" ]]; then
            touch "$LOG_FILE"
            log_info "Created log file"
        fi
    else
        log_info "Path already exist"
    fi
}

# TODO: generate id


# Logging funtion for INFO, ERROR, SUCCESS
function log_message(){
    local level="$1"
    local message="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ${level}: ${message}" >> "$LOG_FILE"
}

function log_task_action(){
    local action="$1"
    local description="$2"
    log_message "ACTION:" "Task ${action} - Desc: ${description}"
}

log_error() {
    log_message "ERROR" "$1"
    echo -e "${RED}Error: $1${NC}" >&2
}

log_success() {
    echo -e "${GREEN}$1${NC}"
    log_message "SUCCESS" "$1"
}

log_info() {
    echo -e "${BLUE}$1${NC}"
    log_message "INFO" "$1"
}

# ==================== END OF UTILITY FUNCTIONS ====================

# ==================== VALIDATE FUNCTIONS ====================

function validate_path(){
    [[ -e "$1"  ]]
}

function validate_priority(){
    [[ "$1" =~ ^(HIGH|MEDIUM|LOW)$  ]]
}

function validate_date(){
    [[ "$1" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$  && $(date -d "$1") ]]
}

function validate_status(){
    [[ "$1" =~ ^(PENDING|COMPLETED)$  ]]
}

function is_input_empty(){
    [[ -z "$1" ]]
}

# ==================== END OF VALIDATE FUNCTIONS ====================

# ==================== TASK OPERATIONS ====================

# Add new tasks
function add_new_task(){
    echo -e "\n${BLUE}--- Add New Task ---${NC}"

    # Get and validate description
    read -p "Enter task description: " description
    if is_input_empty "$description"; then
        log_error "Description cannot be empty"
        return 1
    fi

    # Get category
    read -p "Enter task category (e.g., Work, Personal, Event): " category
    if is_input_empty "$category"; then
        category="General"
        log_info "Category set to default: General"
    fi

    # Get and validate priority
    while true; do
        read -p "Enter task priority (Low, Medium, High): " priority
        priority=$(echo "$priority" | tr '[:lower:]' '[:upper:]')
        if validate_priority "$priority"; then
            break
        else
            echo -e "${YELLOW}Invalid priority. Please use Low, Medium, or High.${NC}"
        fi
    done

    # Get and validate due date
    while true; do
        read -p "Enter task due date (YYYY-MM-DD): " due_date
        if validate_date "$due_date"; then
            break
        else
            echo -e "${YELLOW}Invalid date format. Please use YYYY-MM-DD.${NC}"
        fi
    done

    # TODO: Generate task ID and timestamps
    
    local status="PENDING"

    # Append task to file
    echo "${description},${category},${priority},${due_date},${status},${current_date},${current_date}," >> "$TASK_FILE"

    # Log and confirm
    log_task_action "CREATED" "$description"
    log_success "Task #${task_id} added successfully!"
}

# ==================== END OF TASK OPERATIONS ====================


# Main Menu and User Interaction
function display_main_menu(){
    clear # clear previous terminal commands or output 
    echo ""
    echo "Welcome to using Todo List Manager App"

    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║           TO-DO TASK MANAGER           ║${NC}"
    echo -e "${BLUE}╠════════════════════════════════════════╣${NC}"
    echo -e "${BLUE}║ 1. Add New Task                        ${BLUE}║${NC}"
    echo -e "${BLUE}║ 2. Mark Task as Complete               ${BLUE}║${NC}"
    echo -e "${BLUE}║ 3. Delete Task                         ${BLUE}║${NC}"
    echo -e "${BLUE}║ 4. Filter Tasks                        ${BLUE}║${NC}"
    echo -e "${BLUE}║    ├─ By Category                      ${BLUE}║${NC}"
    echo -e "${BLUE}║    ├─ By Priority                      ${BLUE}║${NC}"
    echo -e "${BLUE}║    └─ By Status                        ${BLUE}║${NC}"
    echo -e "${BLUE}║ 5. Sort Tasks                          ${BLUE}║${NC}"
    echo -e "${BLUE}║    ├─ By Due Date                      ${BLUE}║${NC}"
    echo -e "${BLUE}║    └─ By Priority                      ${BLUE}║${NC}"
    echo -e "${BLUE}║ 6. List All Tasks                      ${BLUE}║${NC}"
    echo -e "${BLUE}║ 7. Search Tasks                        ${BLUE}║${NC}"
    echo -e "${BLUE}║ 8. Statistics & Reports                ${BLUE}║${NC}"
    echo -e "${BLUE}║ 9. Export Tasks                        ${BLUE}║${NC}"
    echo -e "${BLUE}║ 0. Exit                                ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"

    read -p "Please choose an option (0-9): " choice

    case "$choice" in
        1) add_new_task ;;
        2) mark_task_complete ;;
        3) delete_task ;;
        4) filter_tasks ;;
        5) sort_tasks ;;
        6) list_all_tasks ;;
        7) search_tasks ;;
        8) show_statistics ;;
        9) export_tasks ;;
        0) 
            log_info "Goodbye!"
            exit 0
            ;;
        *)
            log_error "Invalid option. Please choose 0-7."
            ;;
    esac
}


# Main function to start running the program
function main(){

    # initialize files and directory
    intialize_task_file     

    
    # Main loop
    while true; do
        display_main_menu
    done

}

# Run main function
main