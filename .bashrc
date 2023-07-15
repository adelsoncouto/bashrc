
# recarrega este arquivo
alias xatualizar="source ~/.bashrc"

# ATIVIDADES

# esta função será utilizada pelas outras funções de atividade
function fCriarArquivoAtividades() {
    _arquivo='Atividade.md'
    
    if [[ $# -ge 1 ]]; then
        _arquivo=${1}
    fi
    
    if [[ ! -f ${_arquivo} ]]; then
        echo '|DATA|TEMPO|STATUS|ACOES|' >> ${_arquivo}
        echo '|---|---|---|---|' >> ${_arquivo}
    fi 
}

# inicia uma atividade, deve ser informado o arquivo onde iniciar veja alias xiatividade
function fIniciarAtividade() {
    _arquivo='Atividade.md'

     if [[ $# -ge 1 ]]; then
        _arquivo=${1}
    fi
    
    fCriarArquivoAtividades ${_arquivo}
    
    _data=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    _inicio=`head -n 1 "${_arquivo}"`
    
    if [[ "${_inicio}" != '#inicio#' ]]; then 
        sed -i "1i\\#inicio#" ${_arquivo}
        sed -i "2i\\$_data" ${_arquivo}
        sed -i "3i\\#fim#" ${_arquivo}
    fi
}

# registra uma sub atividades, a mesma será 
function fRegistrarAtividade() {
    _argumentos=$#
    _atividade=''
    _arquivo='Atividade.md'

    if [[ $_argumentos -ge 2 ]]; then 
        _atividade=`echo -n "${2}" | tr '|;' ','`
        _arquivo=${1}
    elif [[ $_argumentos -ge 1 ]]; then
        _atividade=`echo -n "${1}" | tr '|;' ','`
    fi

    if [[ -n ${_atividade} ]]; then
      fIniciarAtividade ${_arquivo}
      sed -i "3i\\${_atividade}"  ${_arquivo}
    fi
}

function fConcluirAtividade() {
    _arquivo='Atividade.md'
    _atividades=''
    _data=''
    _contador=0
    _existe=0

     if [[ $# -ge 1 ]]; then
        _arquivo=${1}
    fi

    fCriarArquivoAtividades ${_arquivo}
    
    while IFS= read -r linha
    do
        _contador=$(($_contador + 1))
        
        if [[ "${linha}" == '#inicio#' ]]; then
            _existe=1
            continue
        fi

        if [[ $linha == '#fim#' ]]; then
            break
        fi

        if [[ -z $_data ]]; then
            _data=${linha}
            continue
        fi

        _atividades="${linha}; ${_atividades}"

    done < "${_arquivo}"
    
    if [[ $_existe -eq 1 ]]; then 

        sed -i "1,${_contador}d" ${_arquivo}
  
        _dataFim=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        _dataRegitro=`date '+ %d/%m/%Y'`
        _segundosInicio=$(date --date="$_data" +%s)
        _segundosfim=$(date --date="$_dataFim" +%s)
        _totalMinutos=$(( ($_segundosfim - $_segundosInicio) / 60 ))
    
        if [[ $_totalMinutos -lt 10 ]]; then 
            _totalMinutos=10
        fi
        
        _tempo="${_totalMinutos}m"
    
        _status='Finalizada'
    
        if [[ $# -ge 2 ]]; then
            _status=${2}
        fi
    
        echo '| '"${_dataRegitro}"' | '"${_tempo}"' | '${_status}' | '"${_atividades}"' |' >> "${_arquivo}"
    fi

}

# exemplo para dar inicio a uma atividade xiatividade
alias xiatividade="fIniciarAtividade ./Atividades.md "

# exemplo regitrar ações temporárias xratividade 'Atividade xpto'
alias xratividade="fRegistrarAtividade ./Atividades.md "

# exemplo para concluir uma atividade xcatividade 'Finalizada'|'Em andamento'
alias xcatividade="fConcluirAtividade ./Atividades.md "


# GIT
function fGitps () {
	_branch=`git rev-parse --abbrev-ref HEAD`
	git push origin $_branch
}

function fGitpl () {
	_branch=`git rev-parse --abbrev-ref HEAD`
	git pull origin $_branch
}

alias xgitps="fGitps "
alias xgitpl="fGitpl "
alias xgits="git status -s"
alias xgitd="git diff --name-only"
alias xgitr="git restore --staged "
alias xgitb="git rev-parse --abbrev-ref HEAD"

# MVN
alias mvno="mvn clean install -DskipTests=true --offline -T 4 "

# OUTROS
if [[ -f ~/.bashrc2 ]]; then 
    source ~/.bashrc2
fi
