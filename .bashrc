
# recarrega este arquivo
alias xatualizar="source ~/.bashrc"

# GERAL

# como usar
# declare -A nome_array; fLerParam nome_array "$@"
function fLerParam() {
    declare -n _params=$1
    _key=''
    shift

    for n in "$@"; do
            if [[ $n == -* ]]; then
                    _key=${n#-}
                    _params[$_key]=''
            else
                    _params[$_key]=${n}
            fi
    done
}


# ATIVIDADES

# esta função será utilizada pelas outras funções de atividade
function fCriarArquivoAtividades() {
    declare -A _params
    fLerParam _params "$@"
    _arquivo='Atividades.md'

     fi [[ -v _params['h'] ]]; then
        echo "
        ========================================================
        fCriarArquivoAtividades [OPCOES]
        Opções
           -f nome-arquivo.md       Nome do arquivo a ser utilizado para as atividades, o padrão é Atividades.md
           -h                       Exibe essa ajuda
        ========================================================
        "
        exit 0
    fi
    

    if [[ -v _params['f'] ]]; then 
        _arquivo=${_params['f']}
    fi
    
    if [[ ! -f ${_arquivo} ]]; then
        echo '|DATA|TEMPO|STATUS|ACOES|' >> ${_arquivo}
        echo '|---|---|---|---|' >> ${_arquivo}
    fi 
}

# inicia uma atividade, deve ser informado o arquivo onde iniciar veja alias xiatividade
function fIniciarAtividade() {
    declare -A _params
    fLerParam _params "$@"
    _arquivo='Atividades.md'

     fi [[ -v _params['h'] ]]; then
        echo "
        ========================================================
        fIniciarAtividade [OPCOES]
        Opções
           -f nome-arquivo.md       Nome do arquivo a ser utilizado para as atividades, o padrão é Atividades.md
           -h                       Exibe essa ajuda
        ========================================================
        "
        exit 0
    fi
    
    if [[ -v _params['f'] ]]; then 
        _arquivo=${_params['f']}
    fi
    
    fCriarArquivoAtividades -f ${_arquivo}
    
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
    declare -A _params
    _atividade=''
    fLerParam _params "$@"
    _arquivo='Atividades.md'

     fi [[ -v _params['h'] ]]; then
        echo "
        ========================================================
        fRegistrarAtividade [OPCOES]
        Opções
           -f nome-arquivo.md   Nome do arquivo a ser utilizado para as atividades, o padrão é Atividades.md
           -a 'descrição'       Descrição da atividade a ser executada
           -h                   Exibe essa ajuda
        ========================================================
        "
        exit 0
    fi
    
    if [[ -v _params['f'] ]]; then 
        _arquivo=${_params['f']}
    fi

    if [[ -v _params['a'] ]]; then 
        _atividade=`echo -n "${_params['a']}" | tr '|;' ','`
    fi

    if [[ -n ${_atividade} ]]; then
      fIniciarAtividade -f ${_arquivo}
      sed -i "3i\\${_atividade}"  ${_arquivo}
    fi
}

function fConcluirAtividade() {
    declare -A _params
    _atividades=''
    _data=''
    _contador=0
    _existe=0
    _arquivo='Atividades.md'
    fLerParam _params "$@"

     fi [[ -v _params['h'] ]]; then
        echo "
        ========================================================
        fConcluirAtividade [OPCOES]
        Opções
           -f  nome-arquivo.md          Nome do arquivo a ser utilizado para as atividades, o padrão é Atividades.md
           -s  status                   Status da atividade, caso não informe será Finalizada
           -dr yyyy-MM-dd               Data para registrar na atividade
           -df yyyy-MM-ddTHH:mm:SSZ     Data e hora de finalização
           -h                           Exibe essa ajuda
        ========================================================
        "
        exit 0
    fi
    
    if [[ -v _params['f'] ]]; then 
        _arquivo=${_params['f']}
    fi

    fCriarArquivoAtividades -f ${_arquivo}
    
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

        _atividades="${linha}; <br>${_atividades}"

    done < "${_arquivo}"
    
    if [[ $_existe -eq 1 ]]; then 

        sed -i "1,${_contador}d" ${_arquivo}
  
        _dataFim=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        _dataRegitro=`date '+ %Y-%m-%d'`
        if [[ -v _params['df'] ]]; then 
            _dataFim=${_params['df']}
        fi

        if [[ -v _params['dr'] ]]; then 
            _dataRegitro=${_params['dr']}
        fi



        _segundosInicio=$(date --date="$_data" +%s)
        _segundosfim=$(date --date="$_dataFim" +%s)
        _totalMinutos=$(( ($_segundosfim - $_segundosInicio) / 60 ))
    
        if [[ $_totalMinutos -lt 1 ]]; then 
            _totalMinutos=1
        fi
        
        _tempo="    ${_totalMinutos}m"
    
        _status='Finalizada'
    
        if [[ -v _params['s'] ]]; then 
            _status=${_params['s']}
        fi
    
        echo '| '"${_dataRegitro}"' | '"${_tempo: -4}"' | '${_status}' | '"${_atividades}"' |' >> "${_arquivo}"
    fi

}

function fSomarAtividade() {
    _data=`date '+ %Y-%m-%d'`
    _arquivo='Atividades.md'

    if [[ $# -ge 2 ]]; then
        _arquivo=${1}
        _data=${2}
    elif [[ $# -ge 1 ]]; then 
        _data=${1}
    fi

    _minutos=`awk -F '|' '/\|/ {print $2 $3}' ${_arquivo} | egrep "${_data}" | awk '{gsub(/m/, "", $2); total += $2} END {print total}'`
    _hora=$(($_minutos / 60))
    _minuto=$(($_minutos % 60));
    echo $_hora'h'$_minuto'm'
}

# exemplo para dar inicio a uma atividade xiatividade
alias xiatividade="fIniciarAtividade -f ./Atividades.md "

# exemplo regitrar ações temporárias xratividade 'Atividade xpto'
alias xratividade="fRegistrarAtividade -f ./Atividades.md -a "

# exemplo para concluir uma atividade xcatividade 'Finalizada'|'Em andamento'
alias xcatividade="fConcluirAtividade -f ./Atividades.md -df $(date -u +"%Y-%m-%dT%H:%M:%SZ") -dr $(date '+ %Y-%m-%d') "

# exemplo para somar o tempo de hoje das atividades xshatividade 
alias xshatividade="fSomarAtividade -f ./Atividades.md "

# exemplo para somar o tempo em um dia de atividade xsatividade [DATA(aaaa-mm-dd)] 
# caso não informe a data será usado a data atual 
alias xsatividade="fSomarAtividade -f ./Atividades.md "


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
