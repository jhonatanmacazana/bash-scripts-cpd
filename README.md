# Scripts

A collection of simple Bash scripts.

## Installation

### Cluster

1. ssh to the cluster

2. clone this repo to your home directory on any folder

```bash
# i.e. save the repo on ~/.config/scripts
mkdir -p ~/.config
git clone https://github.com/jhonatanmacazana/bash-scripts-cpd ~/.config
```

3. open the shell configuration file (.bashrc | .zshrc) with the prefered editor (nano | vim)

```bash
# if bash
vim ~/.bashrc
```

4. paste the following lines into the bottom of the file

```bash
# if file in ~/.config/scripts/cluster/customFunctions.sh
if [ -f ~/.config/scripts/cluster/customFunctions.sh ]; then
    source ~/.config/scripts/cluster/customFunctions.sh
fi
```

5. restart the session with `source ~/.bashrc`or ssh-out and ssh-in again

## Usage

Custom aliases

```bash
alias oc=f_omp_compile
alias mc=f_mpi_compile
alias moc=f_mpi_omp_compile
alias gen=f_generate_file
```

1. Compilation

```
command input-file.cpp [output-file]
```

-   `command` can be `oc|mc|moc` for omp, mpi or mpi-omp compilation
-   If no `output-file` provided, it will compile to `input-file.out`

2. Output File Generation

```
usage: f_generate_file [-j job-name] [-n number-proc]
                       [-t type] <-o output-file> <-x executable>
```

-   `f_generate` can be replaced with `gen`
-   `output-file` must be provided in the format if `<name>.sh`
-   `executable` must be provided
-   if `job-name` is not provided, it defaults to `CPD-test-$(date +"%T-%D")`
-   if `number-proc` is not provided, it defaults to `4`
-   if `type` is not provided, it defaults to `MPI`.
-   If no output-file provided, it will compile to `input-file.out`

## License

MIT
