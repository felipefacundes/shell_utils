#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes
# Instagram Video Downloader - Professional wrapper

: <<'DOCUMENTATION'
Instagram Video Downloader v2.0.0

DESCRIPTION:
A robust wrapper script for downloading Instagram videos using Instaloader.
Provides professional error handling, logging, and user experience.

FEATURES:
- Automatic dependency management
- Virtual environment isolation
- Progress tracking
- Comprehensive error handling
- Organized file storage
- Professional logging

USAGE:
  instagram-dl [OPTIONS] <Instagram-URL>

OPTIONS:
  -h, --help      Show this help message
  -v, --version   Show version information
  --setup         Force reinstall dependencies
  --clean         Remove virtual environment and reinstall

EXAMPLES:
  instagram-dl https://www.instagram.com/p/CxampleVideo123/
  instagram-dl --setup
  instagram-dl --clean
  instagram-dl --help

DEPENDENCIES:
- Python 3.6+
- pip
- virtualenv
DOCUMENTATION

# Script configuration
VERSION="2.0.0"
SCRIPT_NAME="instagram-dl"

# Paths
PYTHON_SCRIPT_NAME="instagram_download_video.py"
PYTHON_SCRIPT_DIR="${HOME}/.shell_utils/scripts"
PYTHON_SCRIPT_PATH="${PYTHON_SCRIPT_DIR}/${PYTHON_SCRIPT_NAME}"
VIRTUAL_ENV_DIR="${HOME}/.python/instagram_download"
DOWNLOAD_DIR="${HOME}/Downloads/instagram_videos"
LOG_DIR="${HOME}/.cache/instagram-dl"
LOG_FILE="${LOG_DIR}/instagram-dl.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Logging functions
init_logging() {
    mkdir -p "${LOG_DIR}"
    touch "${LOG_FILE}"
}

log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${message}"
    echo "${timestamp} [${level}] ${message}" >> "${LOG_FILE}"
}

log_info() { log "INFO" "$1"; }
log_success() { log "SUCCESS" "$1"; }
log_warning() { log "WARNING" "$1"; }
log_error() { log "ERROR" "$1"; }

# Colored output functions
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; log_info "$1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; log_success "$1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; log_warning "$1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; log_error "$1"; }

# Help and version
show_help() {
    echo -e "${CYAN}Instagram Video Downloader v${VERSION}${NC}"
    echo "Usage: ${SCRIPT_NAME} [OPTIONS] <Instagram-URL>"
    echo ""
    echo "Options:"
    echo "  -h, --help      Show this help message"
    echo "  -v, --version   Show version information"
    echo "  --setup         Force reinstall dependencies"
    echo "  --clean         Remove virtual environment and reinstall"
    echo "  --log           Show log file content"
    echo ""
    echo "Examples:"
    echo "  ${SCRIPT_NAME} https://www.instagram.com/p/CxampleVideo123/"
    echo "  ${SCRIPT_NAME} --setup"
    echo "  ${SCRIPT_NAME} --clean"
    echo "  ${SCRIPT_NAME} --help"
}

show_version() {
    echo -e "${CYAN}${SCRIPT_NAME} v${VERSION}${NC}"
    echo "License: GPLv3"
    echo "Credits: Felipe Facundes"
}

# Dependency checks
check_dependencies() {
    local missing_deps=()
    
    if ! command -v python3 &> /dev/null; then
        missing_deps+=("python3")
    fi
    
    if ! command -v pip3 &> /dev/null; then
        missing_deps+=("pip3")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        print_info "Please install: sudo apt install python3 python3-pip python3-venv"
        exit 1
    fi
}

# Virtual environment management
setup_environment() {
    local force="${1:-false}"
    
    if [[ "$force" == "clean" ]]; then
        print_info "Cleaning existing virtual environment..."
        rm -rf "${VIRTUAL_ENV_DIR}"
    fi
    
    if [[ ! -d "${VIRTUAL_ENV_DIR}" ]] || [[ "$force" != "false" ]]; then
        print_info "Creating virtual environment..."
        python3 -m venv "${VIRTUAL_ENV_DIR}" || {
            print_error "Failed to create virtual environment"
            exit 1
        }
        
        source "${VIRTUAL_ENV_DIR}/bin/activate"
        
        print_info "Installing required packages..."
        pip install --upgrade pip || {
            print_error "Failed to upgrade pip"
            exit 1
        }
        
        pip install instaloader tqdm requests || {
            print_error "Failed to install required packages"
            exit 1
        }
        
        print_success "Environment setup completed"
    else
        source "${VIRTUAL_ENV_DIR}/bin/activate"
    fi
}

# Python script management
ensure_python_script() {
    if [[ ! -f "${PYTHON_SCRIPT_PATH}" ]]; then
        print_error "Python script not found: ${PYTHON_SCRIPT_PATH}"
        print_info "Please ensure the script exists at the specified location"
        exit 1
    fi
    
    # Make script executable
    chmod +x "${PYTHON_SCRIPT_PATH}"
}

# URL validation
validate_url() {
    local url="$1"
    
    if [[ ! "$url" =~ ^https://www.instagram.com/ ]] && \
       [[ ! "$url" =~ ^https://instagram.com/ ]]; then
        print_error "Invalid Instagram URL format"
        print_info "URL must be in format: https://www.instagram.com/p/VIDEO_ID/"
        return 1
    fi
    
    return 0
}

# Main download function
download_video() {
    local url="$1"
    
    print_info "Starting download process..."
    print_info "URL: ${url}"
    print_info "Download directory: ${DOWNLOAD_DIR}"
    
    # Create download directory
    mkdir -p "${DOWNLOAD_DIR}"
    
    # Execute Python script
    if python "${PYTHON_SCRIPT_PATH}" "$url"; then
        print_success "Download completed successfully!"
        return 0
    else
        print_error "Download failed with exit code $?"
        return 1
    fi
}

# Cleanup function
cleanup() {
    if [[ -n "${VIRTUAL_ENV:-}" ]]; then
        deactivate 2>/dev/null || true
    fi
    print_info "Script execution completed"
}

# Main function
main() {
    init_logging
    check_dependencies
    
    local action="download"
    local url=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--version)
                show_version
                exit 0
                ;;
            --setup)
                action="setup"
                shift
                ;;
            --clean)
                action="clean"
                shift
                ;;
            --log)
                action="log"
                shift
                ;;
            *)
                if [[ -z "$url" ]] && [[ "$1" =~ ^https?:// ]]; then
                    url="$1"
                else
                    print_error "Unknown argument: $1"
                    show_help
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # Handle different actions
    case "$action" in
        setup)
            setup_environment "force"
            print_success "Setup completed successfully"
            ;;
        clean)
            setup_environment "clean"
            print_success "Clean setup completed successfully"
            ;;
        log)
            if [[ -f "${LOG_FILE}" ]]; then
                cat "${LOG_FILE}"
            else
                print_info "No log file found"
            fi
            ;;
        download)
            if [[ -z "$url" ]]; then
                print_error "No Instagram URL provided"
                show_help
                exit 1
            fi
            
            if ! validate_url "$url"; then
                exit 1
            fi
            
            ensure_python_script
            setup_environment
            download_video "$url"
            ;;
    esac
}

# Set traps and execute
trap cleanup EXIT INT TERM

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi