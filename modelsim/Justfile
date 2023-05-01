set shell := ["zsh", "-o", "nullglob", "-c"]
set windows-shell := ["powershell", "-c"]

BIN_DIR := "bin"
# The `--std=93c` flag ensures that we are using the VHDL-93 standard.
# If you wish to use the VHDL-2008 standard, specify `--std=08` instead.
# 
# Note that GHDL only has partial support for VHDL-2008.
GHDL_MODS := "-fsynopsys -fexplicit -fcolor-diagnostics --std=93c"
GHDL_FLAGS := GHDL_MODS + " --workdir=" + BIN_DIR


# This command analyses all files
# in the current directory, and all sub-directories.
# 
# Analysing files checks them for syntax errors,
# and registers the entitys/components/architectures
# that are in the VHDL files.
#
# This command accepts an optional parameter called pattern.
# If a filename matches this pattern in any subdirectory, this
# file will be added to the list of files to analyse
#
# This (kind of) is equivalent to 'compilation', but it isn't really
# 
# TL;DR:
# Analyse/compile selected files
[macos]
analyse PATTERN='**/*.vh{d,dl}': _ensure_bin_dir
	ghdl -a {{GHDL_FLAGS}} {{PATTERN}}


# Analyse/compile selected files
[windows]
analyse NAME_PAT='*.vhd' RECURSE="-r": _ensure_bin_dir
	gci {{RECURSE}} -fi {{NAME_PAT}} | % { ghdl -a {{GHDL_FLAGS}} $_ }


# List the entities that are available
[windows]
list-entities: analyse
	@echo "`n$([char]27)[1;32mEntities:$([char]27)[0m"
	@cat ./bin/work-obj*.cf | sls -patt 'entity ([a-zA-Z0-9_]+) at .*' -all  |% { $_.Matches.Groups } |? name -eq 1 | Sort-Object | % { echo " - $_" }


# List the entities that are available
[macos]
list-entities: analyse
	@echo "\\n\\033[1;32mEntities:\\033[0m"
	@cat {{BIN_DIR}}/work-obj*.cf | sed -nE 's/entity ([a-zA-Z0-9_]+) at .*/- \1/p' | sort
	

# Delete all build files
clean: _ensure_bin_dir
	ghdl clean {{GHDL_FLAGS}}
	rm -rf {{BIN_DIR}}/*

# Compile all, and simulate a design unit
sim UNIT STOP_TIME OUT='sim_wav.ghw': (_elaborate UNIT) (_sim UNIT STOP_TIME OUT)


# Synthesises a design. Creates a graphiz dot file.
synth UNIT FMT="dot": _ensure_bin_dir
	ghdl --synth {{GHDL_FLAGS}} --out={{FMT}} {{UNIT}} 


# Opens GTKWave with the default wave file
[windows]
open-gtkwave FILE='sim_wav.ghw':
    Start-Process -FilePath "gtkwave" -ArgumentList "{{FILE}}"


# Opens GTKWave with the default wave file
[macos]
open-gtkwave FILE='sim_wav.ghw':
    open /Applications/gtkwave.app {{FILE}}


# Make sure that binary dir always exists
[windows]
_ensure_bin_dir:
	@mkdir {{BIN_DIR}} -ErrorAction Ignore | Out-Null; $global:LastExitCode = 0


# Make sure that binary dir always exists
[macos]
_ensure_bin_dir:
	@mkdir {{BIN_DIR}} &> /dev/null || true


# This option should only be used
# if you have a custom install of GHDL that
# uses GCC or LLVM. If you don't know what that
# means, then you probably don't need to run
# this command
# 
# You probably don't need to run this command
_elaborate UNIT: analyse
	ghdl -e {{GHDL_FLAGS}} {{UNIT}}


# This command simulates a VHDL design unit,
# and outputs a waveform. It does not precompile
# any code.
#
# TL;DR:
# Simulate the chosen design unit, and output a waveform, wo/ compiling first
_sim UNIT STOP_TIME OUT='sim_wav.ghw': _ensure_bin_dir
    ghdl -r {{GHDL_FLAGS}} {{UNIT}}  --stop-time={{STOP_TIME}} --wave={{OUT}}


