# docker-manager-completion.zsh

# docker-manager zsh completion
compdef _docker_manager docker-manager

_docker_manager() {
    local -a commands
    local curcontext="$curcontext" state line
    typeset -A opt_args
    
    commands=(
        'run:Create and start new container'
        'enter:Enter running container'
        'start:Start and enter container'
        'temp:Temporary container (--rm)'
        'ls:List containers'
        'ps:List containers'
        'stop:Stop container'
        'restart:Restart container'
        'rm:Remove container'
        'rename:Rename container'
        'exec:Execute command in container'
        'logs:View logs'
        'stats:Real-time statistics'
        'top:Container processes'
        'info:Detailed information'
        'ip:Show IP'
        'ports:Mapped ports'
        'inspect:Full inspect'
        'images:List images'
        'rmi:Remove image'
        'pull:Pull image'
        'search:Search images'
        'clean:Smart cleanup'
        'clean-all:Complete cleanup'
        'prune:Remove all unused items'
        'nuke:Nuclear option'
        'daemon:Run as daemon'
        'user:Run as current user'
        'health:Check Docker health'
        'version:Docker versions'
        'history:Command history'
        'help:Help'
    )
    
    _arguments -C \
        "1: :->cmds" \
        "*::arg:->args"
    
    case $state in
        cmds)
            _describe 'docker-manager commands' commands
            ;;
        args)
            case $line[1] in
                run)
                    _arguments \
                        '--name[Container name]' \
                        '--port[Port mapping]' \
                        '--volume[Volume mount]' \
                        '--env[Environment variable]' \
                        '--network[Network]' \
                        '--user[User]' \
                        '--rm[Auto-remove]' \
                        '-it[Interactive mode]' \
                        '-d[Detached mode]' \
                        '*:image:_docker_images'
                    ;;
                enter|start|stop|restart|rm|logs|top|info|ip|ports|inspect|daemon|user)
                    _arguments '*:container:_docker_containers'
                    ;;
                exec)
                    _arguments \
                        '1:container:_docker_containers' \
                        '*:command: _command_names -e'
                    ;;
                rename)
                    _arguments \
                        '1:old container:_docker_containers' \
                        '2:new name:'
                    ;;
                temp|pull)
                    _arguments '1:image:_docker_images'
                    ;;
                rmi)
                    _arguments '1:image:_docker_images'
                    ;;
                search)
                    _arguments '1:search term:'
                    ;;
            esac
            ;;
    esac
}

# Helper functions for zsh
_docker_containers() {
    local -a containers
    containers=(${(f)"$(docker ps -a --format "{{.Names}}" 2>/dev/null)"})
    _describe 'containers' containers
}

_docker_images() {
    local -a images
    images=(${(f)"$(docker images --format "{{.Repository}}:{{.Tag}}" 2>/dev/null | grep -v '<none>')"})
    _describe 'images' images
}

# Alias for dm
compdef _docker_manager dm