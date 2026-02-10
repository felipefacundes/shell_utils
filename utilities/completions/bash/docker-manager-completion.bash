# docker-manager bash completion
# To use: source this file or place it in /etc/bash_completion.d/ or ~/.bash_completion.d

# Load completions from home directory, add in ~/.bashrc
# if [ -d ~/.bash_completion.d ]; then
#     for completion in ~/.bash_completion.d/*.bash; do
#         [ -f "$completion" ] && . "$completion"
#     done
# fi

_docker_manager() {
    local cur prev words cword
    _init_completion || return

    local commands="run enter start temp ls ps stop restart rm rename exec logs stats top info ip ports inspect images rmi pull search clean clean-all prune nuke daemon user health version history help"
    
    local containers=$(docker ps -a --format "{{.Names}}" 2>/dev/null)
    local images=$(docker images --format "{{.Repository}}:{{.Tag}}" 2>/dev/null)
    local running_containers=$(docker ps --format "{{.Names}}" 2>/dev/null)
    
    case "${cword}" in
        1)
            # First argument: main commands
            COMPREPLY=($(compgen -W "$commands" -- "$cur"))
            ;;
        2)
            # Second argument: depends on command
            case "${words[1]}" in
                # Commands that accept container name
                enter|start|exec|logs|stop|restart|rm|top|info|ip|ports|inspect|daemon|user)
                    COMPREPLY=($(compgen -W "$containers" -- "$cur"))
                    ;;
                
                # Commands that accept container name (only running)
                exec|logs|top|info|ip|ports|inspect|user)
                    COMPREPLY=($(compgen -W "$running_containers" -- "$cur"))
                    ;;
                
                # Commands that accept images
                run|temp|pull)
                    # Suggests local images first, then popular images
                    local local_images=$(docker images --format "{{.Repository}}" 2>/dev/null | sort -u)
                    if [[ -z "$cur" ]]; then
                        COMPREPLY=($(compgen -W "$local_images" -- "$cur"))
                    else
                        COMPREPLY=($(compgen -W "$local_images" -- "$cur"))
                    fi
                    ;;
                
                # Commands that accept image name for removal
                rmi)
                    COMPREPLY=($(compgen -W "$images" -- "$cur"))
                    ;;
                
                # rename command needs two containers
                rename)
                    COMPREPLY=($(compgen -W "$containers" -- "$cur"))
                    ;;
                
                # search command accepts any term
                search)
                    # Suggests common terms
                    local common_terms="nginx mysql postgres redis ubuntu alpine centos debian python node java golang"
                    COMPREPLY=($(compgen -W "$common_terms" -- "$cur"))
                    ;;
                
                # exec command needs a command after the container
                exec)
                    if [[ -n "$cur" ]]; then
                        # If container already specified, suggests common commands
                        local common_cmds="bash sh ps aux top ls cat grep find"
                        COMPREPLY=($(compgen -W "$common_cmds" -- "$cur"))
                    fi
                    ;;
                
                # Help with subcommands
                help)
                    COMPREPLY=($(compgen -W "$commands" -- "$cur"))
                    ;;
                
                # Commands without additional arguments
                ls|ps|stats|clean|clean-all|prune|nuke|health|version|history|images)
                    COMPREPLY=()
                    ;;
            esac
            ;;
        3)
            # Third argument
            case "${words[1]}" in
                # rename needs the new name
                rename)
                    # Doesn't suggest anything specific for new name
                    COMPREPLY=()
                    ;;
                
                # exec needs the command
                exec)
                    if [[ "${words[2]}" != "" ]]; then
                        # Container already specified, suggests commands
                        local common_cmds="bash sh python node npm php java go ps aux top htop \
                                          ls cat grep find curl wget ping ssh mysql psql mongosh \
                                          apt-get yum apk pip npm yarn docker-compose git"
                        COMPREPLY=($(compgen -W "$common_cmds" -- "$cur"))
                    fi
                    ;;
                
                # run can have various options
                run)
                    # Suggests run command options
                    local run_options="--name --port --volume --env --network --user --rm -it -d -p -v -e"
                    COMPREPLY=($(compgen -W "$run_options" -- "$cur"))
                    ;;
            esac
            ;;
        *)
            # Additional arguments
            case "${words[1]}" in
                run)
                    # For run command, processes options
                    local last_opt="${words[$cword-1]}"
                    
                    case "$last_opt" in
                        --name|--port|--volume|--env|--network|--user)
                            # These options need a value
                            COMPREPLY=()
                            ;;
                        -p)
                            # Suggests common ports
                            local common_ports="80:80 443:443 8080:80 3000:3000 3306:3306 5432:5432 6379:6379"
                            COMPREPLY=($(compgen -W "$common_ports" -- "$cur"))
                            ;;
                        -v)
                            # Suggests common paths
                            local common_volumes="\$(pwd):/app ~/.ssh:/root/.ssh /var/run/docker.sock:/var/run/docker.sock"
                            COMPREPLY=($(compgen -W "$common_volumes" -- "$cur"))
                            ;;
                        -e)
                            # Suggests common environment variables
                            local common_envs="DEBUG=true DATABASE_URL= POSTGRES_PASSWORD= MYSQL_ROOT_PASSWORD= \
                                              REDIS_URL= NODE_ENV=production JAVA_OPTS="
                            COMPREPLY=($(compgen -W "$common_envs" -- "$cur"))
                            ;;
                        *)
                            # Other options
                            local run_opts="--name= --port= --volume= --env= --network= --user= --rm -it -d -p= -v= -e="
                            COMPREPLY=($(compgen -W "$run_opts" -- "$cur"))
                            ;;
                    esac
                    ;;
                
                # For other commands, doesn't suggest anything
                *)
                    COMPREPLY=()
                    ;;
            esac
            ;;
    esac
    
    # Special handling for options with =
    if [[ ${#COMPREPLY[@]} -eq 1 && "$cur" == *=* ]]; then
        # If user already started with =, don't add space
        compopt -o nospace
    elif [[ "$cur" == --* || "$cur" == -* ]]; then
        # For options starting with -- or -, don't add space
        compopt -o nospace
    fi
}

# Function to complete Docker images (used internally)
__docker_manager_complete_images() {
    local cur="$1"
    local images=$(docker images --format "{{.Repository}}:{{.Tag}}" 2>/dev/null | grep -v '<none>' | sort -u)
    COMPREPLY=($(compgen -W "$images" -- "$cur"))
}

# Function to complete containers (used internally)
__docker_manager_complete_containers() {
    local cur="$1"
    local state="$2"  # all, running, stopped
    
    case "$state" in
        running)
            local containers=$(docker ps --format "{{.Names}}" 2>/dev/null)
            ;;
        stopped)
            local containers=$(docker ps -a --filter "status=exited" --format "{{.Names}}" 2>/dev/null)
            ;;
        all|*)
            local containers=$(docker ps -a --format "{{.Names}}" 2>/dev/null)
            ;;
    esac
    
    COMPREPLY=($(compgen -W "$containers" -- "$cur"))
}

# Function to complete Docker networks
__docker_manager_complete_networks() {
    local cur="$1"
    local networks=$(docker network ls --format "{{.Name}}" 2>/dev/null)
    COMPREPLY=($(compgen -W "$networks" -- "$cur"))
}

# Function to complete Docker volumes
__docker_manager_complete_volumes() {
    local cur="$1"
    local volumes=$(docker volume ls --format "{{.Name}}" 2>/dev/null)
    COMPREPLY=($(compgen -W "$volumes" -- "$cur"))
}

# Function to suggest image tags
__docker_manager_complete_image_tags() {
    local cur="$1"
    local image_name="$2"
    
    if [[ -n "$image_name" ]]; then
        local tags=$(docker images --format "{{.Tag}}" "$image_name" 2>/dev/null | sort -u)
        COMPREPLY=($(compgen -W "$tags" -- "$cur"))
    fi
}

# Function to suggest popular Docker commands
__docker_manager_complete_docker_commands() {
    local cur="$1"
    local docker_cmds="build push pull login logout tag save load import export \
                      cp diff commit kill pause unpause wait events update \
                      swarm node service stack config secret"
    COMPREPLY=($(compgen -W "$docker_cmds" -- "$cur"))
}

# Function to suggest available shells
__docker_manager_complete_shells() {
    local cur="$1"
    local shells="bash sh zsh fish dash ksh tcsh csh"
    COMPREPLY=($(compgen -W "$shells" -- "$cur"))
}

# Registers completion for docker-manager
complete -F _docker_manager docker-manager

# Also registers for alias 'dm' if it exists
if type dm &>/dev/null; then
    complete -F _docker_manager dm
fi

# If you have alias 'd' for docker, we can also complete it
if alias d 2>/dev/null | grep -q "docker"; then
    # Uses standard Docker completion if available
    if declare -f _docker >/dev/null; then
        complete -F _docker d
    fi
fi

# Help function to show available options
_docker_manager_help() {
    echo "Available commands for docker-manager:"
    echo "  run       - Create and start new container"
    echo "  enter     - Enter running container"
    echo "  start     - Start and enter container"
    echo "  temp      - Temporary container (--rm)"
    echo "  ls/ps     - List containers"
    echo "  stop      - Stop container"
    echo "  restart   - Restart container"
    echo "  rm        - Remove container"
    echo "  rename    - Rename container"
    echo "  exec      - Execute command in container"
    echo "  logs      - View logs"
    echo "  stats     - Real-time statistics"
    echo "  top       - Processes in container"
    echo "  info      - Detailed information"
    echo "  ip        - Show IP"
    echo "  ports     - Mapped ports"
    echo "  inspect   - Complete inspect"
    echo "  images    - List images"
    echo "  rmi       - Remove image"
    echo "  pull      - Download image"
    echo "  search    - Search for images"
    echo "  clean     - Intelligent cleanup"
    echo "  clean-all - Complete cleanup"
    echo "  prune     - Remove everything unused"
    echo "  nuke      - Nuclear option (caution!)"
    echo "  daemon    - Run as daemon"
    echo "  user      - Execute as current user"
    echo "  health    - Check Docker health"
    echo "  version   - Docker versions"
    echo "  history   - Command history"
    echo "  help      - This help"
}

# Adds shortcut to show help
alias dm-help='_docker_manager_help'

# Configuration to show suggestions in real time
if [[ $- == *i* ]]; then
    # Interactive mode
    bind 'set show-all-if-ambiguous on'
    bind 'set completion-ignore-case on'
    bind 'TAB:menu-complete'
fi

# Function to generate completion cache (optional)
_docker_manager_cache() {
    local cache_file="${HOME}/.docker-manager-completion-cache"
    local cache_age=300  # 5 minutes
    
    if [[ -f "$cache_file" ]]; then
        local now=$(date +%s)
        local file_age=$(stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file")
        
        if (( now - file_age < cache_age )); then
            source "$cache_file"
            return
        fi
    fi
    
    # Generates cache
    {
        echo "DOCKER_MANAGER_CONTAINERS=($(docker ps -a --format '"{{.Names}}"' 2>/dev/null))"
        echo "DOCKER_MANAGER_IMAGES=($(docker images --format '"{{.Repository}}:{{.Tag}}"' 2>/dev/null | grep -v '<none>'))"
        echo "DOCKER_MANAGER_NETWORKS=($(docker network ls --format '"{{.Name}}"'))"
        echo "DOCKER_MANAGER_VOLUMES=($(docker volume ls --format '"{{.Name}}"'))"
    } > "$cache_file"
}

# Updates cache in background (if supported)
if command -v bg &>/dev/null; then
    (_docker_manager_cache &) 2>/dev/null
fi

# Initialization message (optional)
# if [[ $- == *i* ]]; then
#     echo -e "\033[36mDocker Manager completion loaded. Use 'dm-help' for help.\033[0m" >&2
# fi