#!/bin/bash

_THIS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

function f_mpi_compile() {
    THIS_FUNC_NAME=${FUNCNAME[0]}
    case "$#" in
    1)
        NAME_TEMP=$(echo "$1" | cut -d'.' -f1).out
        ;;
    2)
        NAME_TEMP="$2"
        ;;
    \?)
        printf "usage: %s source-file [output-file]\n" "${THIS_FUNC_NAME}"
        ;;
    esac

    module load openmpi/2.1.6
    mpic++ -o "$NAME_TEMP" -g "$1"
    module unload openmpi/2.1.6
}

function f_omp_compile() {
    THIS_FUNC_NAME=${FUNCNAME[0]}
    case "$#" in
    1)
        NAME_TEMP=$(echo "$1" | cut -d'.' -f1).out
        ;;
    2)
        NAME_TEMP="$2"
        ;;
    \?)
        printf "usage: %s source-file [output-file]\n" "${THIS_FUNC_NAME}"
        ;;
    esac

    module load gcc/5.5.0
    g++ -o "$NAME_TEMP" -g "$1" -fopenmp -lpthread
    module unload gcc/5.5.0
}

function f_mpi_omp_compile() {
    THIS_FUNC_NAME=${FUNCNAME[0]}
    case "$#" in
    1)
        NAME_TEMP=$(echo "$1" | cut -d'.' -f1).out
        ;;
    2)
        NAME_TEMP="$2"
        ;;
    \?)
        printf "usage: %s source-file [output-file]\n" "${THIS_FUNC_NAME}"
        return 1
        ;;
    esac

    module load gcc/5.5.0 openmpi/2.1.6
    mpic++ -o "$NAME_TEMP" -g "$1" -fopenmp -lpthread
    module unload gcc/5.5.0 openmpi/2.1.6
}

function f_generate_file() {

    jflag=
    oflag=
    nflag=
    tflag=
    xflag=

    THIS_FUNC_NAME=${FUNCNAME[0]}

    function usage() {
        printf "usage: %s [-j job-name] [-n number-proc]\n" "${THIS_FUNC_NAME}"
        printf "       %${#THIS_FUNC_NAME}s [-t type] <-o output-file> <-x executable>\n\n" ""
        return 2
    }

    # Handle x flag -> executable to run
    if [ "$#" -eq 0 ]; then
        usage
        return 2
    fi

    local OPTIND
    while getopts "j:o:n:t:x:" temp_name1; do
        case $temp_name1 in
        j)
            jflag=1
            JOB_NAME="$OPTARG"
            ;;
        o)
            oflag=1
            OUTPUT_FILE="$OPTARG"
            ;;
        n)
            nflag=1
            NUM_PRO="$OPTARG"
            ;;
        t)
            tflag=1
            TYPE_PAR="$OPTARG"
            ;;
        x)
            xflag=1
            EX_NAME=$OPTARG
            ;;
        \?)
            usage
            return 2
            ;;
        esac
    done
    shift $((OPTIND - 1))

    # Handle o flag -> output file to be generated
    OUTPUT_FILE_EXT=$(echo $OUTPUT_FILE | cut -d '.' -f2)
    if [ "$OUTPUT_FILE_EXT" != "sh" ]; then
        printf "Output-file must be <filename>.sh\n" >&2
        return 1
    fi

    # Handle x flag -> executable to run
    if [ -z "$xflag" ] || [ -z "$EX_NAME" ]; then
        printf "Executable (-x) required" >&2
        return 1
    fi

    # Handle J flag -> job name
    if [ -z "$jflag" ]; then
        JOB_NAME="CPD-test-$(date +"%T-%D")"
    fi

    # Handle n flag -> number of proccesors
    if [ -z "$nflag" ]; then
        NUM_PRO=4
    else
        if ! [ "$NUM_PRO" -eq "$NUM_PRO" ] 2>/dev/null; then
            printf "Number of procesors (-n) must be an integer" >&2
            return 1
        fi
    fi

    # Handle t flag -> type of parallelism
    if [ -z "$tflag" ]; then
        TYPE_PAR='MPI'
    else
        if [ $TYPE_PAR != 'MPI' ] && [ $TYPE_PAR != 'OMP' ] && [ $TYPE_PAR != 'ALL' ]; then
            printf "Type (-t) must be MPI, OMP or ALL" >&2
            return 1
        fi
    fi

    echo "Output file: $OUTPUT_FILE"
    echo "Ex. file:    $EX_NAME"
    echo "Job:         $JOB_NAME"
    echo "N.proc:      $NUM_PRO"
    echo "Type:        $TYPE_PAR"

    rm -f $OUTPUT_FILE
    cat >$OUTPUT_FILE <<EOF
#!/bin/bash
#SBATCH -J $JOB_NAME
#SBATCH -p investigacion
EOF

    case $TYPE_PAR in
    'MPI')
        cat >>$OUTPUT_FILE <<EOF
#SBATCH --tasks-per-node=$NUM_PRO

module load openmpi/2.1.6
mpirun -np $NUM_PRO $EX_NAME
module unload openmpi/2.1.6
EOF
        ;;
    'OMP')
        cat >>$OUTPUT_FILE <<EOF
#SBATCH -N 1
#SBATCH --tasks-per-node=$NUM_PRO

module load gcc/5.5.0
unset OMP_NUM_THREADS
./$EX_NAME \${SLURM_NPROCS}
module unload gcc/5.5.0
EOF
        ;;
    'ALL')
        cat >>$OUTPUT_FILE <<EOF
#SBATCH -N $NUM_PRO

module load gcc/5.5.0 openmpi/2.1.6
mpirun -np $NUM_PRO $EX_NAME
module unload gcc/5.5.0 openmpi/2.1.6
EOF
        ;;
    esac

    return 0

}

alias oc=f_omp_compile
alias mc=f_mpi_compile
alias moc=f_mpi_omp_compile
alias gen=f_generate_file

alias l='ls -lah'
alias la='ls -lAh'
alias ll='ls -lh'
alias brc='vim ~/.bashrc'
alias sbrc='source ~/.bashrc'
alias cfrc='vim $_THIS_DIR/customFunctions.sh'
