# WebWords Multi-Language Implementation Makefile
# ================================================
# Self-documenting build system for all programming language implementations
# Each language has build, serve, test, and cleanup targets

.PHONY: help all build-all test-all clean-all
.DEFAULT_GOAL := help

# Note: All commands use hardcoded values so developers can copy/paste for learning

# Benchmarking configuration
BENCHMARK_FILE := benchmarks.csv
TIMESTAMP := $(shell date '+%Y-%m-%d %H:%M:%S')
START_TIME := $(shell date +%s.%N)

# Help target - shows available commands
help: ## Show this help message
	@echo "WebWords Multi-Language Build System"
	@echo "===================================="
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Language-specific workflow example:"
	@echo "  make build-python && make serve-python && make functional-test-python"
	@echo ""
	@echo "Build all languages:"
	@echo "  make build-all"
	@echo ""
	@echo "Test all languages (concurrent options):"
	@echo "  make test-all           # Use all CPU cores (default)"
	@echo "  make test-all-fast      # Maximum concurrency"
	@echo "  make test-all-conservative  # Half CPU cores (safer)"
	@echo "  make test-all-quad      # 4 concurrent jobs"
	@echo "  make test-all-single    # 1 job (safest, slowest)"
	@echo "  make test-all-custom JOBS=6  # Custom job count"
	@echo "  make system-info        # Show system capabilities for testing"

# Global targets
all: build-all test-all ## Build and test all language implementations

build-all: ## Build all Docker images in parallel with progress bar
	./scripts/build-all.sh

build-all-serial: build-go build-python build-js build-ruby build-php build-java build-csharp build-rust build-cpp build-c build-kotlin build-scala build-perl build-lua build-elixir build-dart build-r build-haskell build-ocaml build-fsharp build-clojure build-crystal build-nim build-erlang build-julia build-deno build-zig build-v build-odin build-bash build-cobol build-fortran build-assembly build-prolog build-matlab build-powershell build-brainfuck build-sql build-vbnet build-tcl build-awk ## Build all Docker images serially

test-all: ## Test all built implementations concurrently using all CPU cores with random ports for speed
	./scripts/test-all.sh

test-all-fast: ## Test all implementations with maximum concurrency (use all CPU cores)
	WEBWORDS_CONCURRENT_JOBS=$$(nproc) ./scripts/test-all.sh

test-all-conservative: ## Test all implementations with conservative concurrency (half CPU cores)
	WEBWORDS_CONCURRENT_JOBS=$$((($$(nproc) + 1) / 2)) ./scripts/test-all.sh

test-all-single: ## Test all implementations with single concurrent job (safest, slowest)
	WEBWORDS_CONCURRENT_JOBS=1 ./scripts/test-all.sh

test-all-quad: ## Test all implementations with 4 concurrent jobs (good for most systems)
	WEBWORDS_CONCURRENT_JOBS=4 ./scripts/test-all.sh

test-all-octa: ## Test all implementations with 8 concurrent jobs (for high-end systems)
	WEBWORDS_CONCURRENT_JOBS=8 ./scripts/test-all.sh

test-all-custom: ## Test all implementations with custom job count (usage: make test-all-custom JOBS=6)
	@if [ -z "$(JOBS)" ]; then \
		echo "Usage: make test-all-custom JOBS=<number>"; \
		echo "Example: make test-all-custom JOBS=6"; \
		exit 1; \
	fi
	WEBWORDS_CONCURRENT_JOBS=$(JOBS) ./scripts/test-all.sh

test-all-debug: ## Test all implementations with debug settings (slow startup, detailed output)
	WEBWORDS_CONCURRENT_JOBS=2 WEBWORDS_STARTUP_WAIT=5 ./scripts/test-all.sh

test-all-serial: functional-test-go functional-test-python functional-test-js functional-test-ruby functional-test-php functional-test-java functional-test-csharp functional-test-rust functional-test-cpp functional-test-c functional-test-kotlin functional-test-scala functional-test-perl functional-test-lua functional-test-elixir functional-test-dart functional-test-r functional-test-haskell functional-test-ocaml functional-test-fsharp functional-test-clojure functional-test-crystal functional-test-nim functional-test-erlang functional-test-julia functional-test-deno functional-test-zig functional-test-v functional-test-odin functional-test-bash functional-test-cobol functional-test-fortran functional-test-assembly functional-test-prolog functional-test-matlab functional-test-powershell functional-test-brainfuck functional-test-sql functional-test-vbnet functional-test-tcl functional-test-awk ## Test all implementations (old serial method)

clean-all: clean-go clean-python clean-js clean-ruby clean-php clean-java clean-csharp clean-rust clean-cpp clean-c clean-kotlin clean-scala clean-perl clean-lua clean-elixir clean-dart clean-r clean-haskell clean-ocaml clean-fsharp clean-clojure clean-crystal clean-nim clean-erlang clean-julia clean-deno clean-zig clean-v clean-odin clean-bash clean-cobol clean-fortran clean-assembly clean-prolog clean-matlab clean-powershell clean-brainfuck clean-sql clean-vbnet clean-tcl clean-awk ## Clean all containers and images

# Go implementation
build-go: ## Build Go Docker image
	cd go && docker build -t webwords-go .

serve-go: ## Run Go container on port 31337
	docker run -d -p 31337:31337 --name webwords-go-server webwords-go

# Shared functional test - all implementations use the same API
functional-test: ## Test any running WebWords implementation on port 31337
	@echo "Testing WebWords API implementation..."
	@echo "Positive test (should return 'true'):"
	@start_time=$$(date +%s.%N); \
	response=$$(curl -s "http://localhost:31337/?keyword=potato&target=https://www.remarkbox.com"); \
	end_time=$$(date +%s.%N); \
	response_time=$$(echo "$$end_time - $$start_time" | bc -l); \
	echo "$$response (response time: $${response_time}s)"
	@echo ""
	@echo "Negative test (should return 'false'):"
	@start_time=$$(date +%s.%N); \
	response=$$(curl -s "http://localhost:31337/?keyword=lemon&target=https://www.remarkbox.com"); \
	end_time=$$(date +%s.%N); \
	response_time=$$(echo "$$end_time - $$start_time" | bc -l); \
	echo "$$response (response time: $${response_time}s)"
	@echo ""

functional-test-go: functional-test ## Test Go implementation (requires running container)

clean-go: ## Stop and remove Go container and image
	-docker stop webwords-go-server
	# -docker rm webwords-go-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-go

# Python implementation
build-python: ## Build Python Docker image
	cd python && docker build -t webwords-python .

serve-python: ## Run Python container on port 31337
	docker run -d -p 31337:31337 --name webwords-python-server webwords-python

functional-test-python: functional-test ## Test Python implementation (requires running container)

clean-python: ## Stop and remove Python container and image
	-docker stop webwords-python-server
	# -docker rm webwords-python-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-python

# JavaScript implementation
build-js: ## Build JavaScript Docker image
	cd js && docker build -t webwords-js .

serve-js: ## Run JavaScript container on port 31337
	docker run -d -p 31337:31337 --name webwords-js-server webwords-js

functional-test-js: functional-test ## Test JavaScript implementation (requires running container)

clean-js: ## Stop and remove JavaScript container and image
	-docker stop webwords-js-server
	# -docker rm webwords-js-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-js

# Ruby implementation
build-ruby: ## Build Ruby Docker image
	cd ruby && docker build -t webwords-ruby .

serve-ruby: ## Run Ruby container on port 31337
	docker run -d -p 31337:31337 --name webwords-ruby-server webwords-ruby

functional-test-ruby: functional-test ## Test Ruby implementation (requires running container)

clean-ruby: ## Stop and remove Ruby container and image
	-docker stop webwords-ruby-server
	# -docker rm webwords-ruby-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-ruby

# PHP implementation
build-php: ## Build PHP Docker image
	cd php && docker build -t webwords-php .

serve-php: ## Run PHP container on port 31337
	docker run -d -p 31337:31337 --name webwords-php-server webwords-php

functional-test-php: functional-test ## Test PHP implementation (requires running container)

clean-php: ## Stop and remove PHP container and image
	-docker stop webwords-php-server
	# -docker rm webwords-php-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-php

# Java implementation
build-java: ## Build Java Docker image
	cd java && docker build -t webwords-java .

serve-java: ## Run Java container on port 31337
	docker run -d -p 31337:31337 --name webwords-java-server webwords-java

functional-test-java: functional-test ## Test Java implementation (requires running container)

clean-java: ## Stop and remove Java container and image
	-docker stop webwords-java-server
	# -docker rm webwords-java-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-java

# C# implementation
build-csharp: ## Build C# Docker image
	cd csharp && docker build -t webwords-csharp .

serve-csharp: ## Run C# container on port 31337
	docker run -d -p 31337:31337 --name webwords-csharp-server webwords-csharp

functional-test-csharp: functional-test ## Test csharp implementation (requires running container)

clean-csharp: ## Stop and remove C# container and image
	-docker stop webwords-csharp-server
	# -docker rm webwords-csharp-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-csharp

# Rust implementation
build-rust: ## Build Rust Docker image
	cd rust && docker build -t webwords-rust .

serve-rust: ## Run Rust container on port 31337
	docker run -d -p 31337:31337 --name webwords-rust-server webwords-rust

functional-test-rust: functional-test ## Test rust implementation (requires running container)

clean-rust: ## Stop and remove Rust container and image
	-docker stop webwords-rust-server
	# -docker rm webwords-rust-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-rust

# C++ implementation
build-cpp: ## Build C++ Docker image
	cd cpp && docker build -t webwords-cpp .

serve-cpp: ## Run C++ container on port 31337
	docker run -d -p 31337:31337 --name webwords-cpp-server webwords-cpp

functional-test-cpp: functional-test ## Test cpp implementation (requires running container)

clean-cpp: ## Stop and remove C++ container and image
	-docker stop webwords-cpp-server
	# -docker rm webwords-cpp-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-cpp

# C implementation
build-c: ## Build C Docker image
	cd c && docker build -t webwords-c .

serve-c: ## Run C container on port 31337
	docker run -d -p 31337:31337 --name webwords-c-server webwords-c

functional-test-c: functional-test ## Test c implementation (requires running container)

clean-c: ## Stop and remove C container and image
	-docker stop webwords-c-server
	# -docker rm webwords-c-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-c

# Kotlin implementation
build-kotlin: ## Build Kotlin Docker image
	cd kotlin && docker build -t webwords-kotlin .

serve-kotlin: ## Run Kotlin container on port 31337
	docker run -d -p 31337:31337 --name webwords-kotlin-server webwords-kotlin

functional-test-kotlin: functional-test ## Test kotlin implementation (requires running container)

clean-kotlin: ## Stop and remove Kotlin container and image
	-docker stop webwords-kotlin-server
	# -docker rm webwords-kotlin-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-kotlin

# Swift implementation
build-swift: ## Build Swift Docker image
	cd swift && docker build -t webwords-swift .

serve-swift: ## Run Swift container on port 31337
	docker run -d -p 31337:31337 --name webwords-swift-server webwords-swift

functional-test-swift: functional-test ## Test swift implementation (requires running container)

clean-swift: ## Stop and remove Swift container and image
	-docker stop webwords-swift-server
	# -docker rm webwords-swift-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-swift

# Scala implementation
build-scala: ## Build Scala Docker image
	cd scala && docker build -t webwords-scala .

serve-scala: ## Run Scala container on port 31337
	docker run -d -p 31337:31337 --name webwords-scala-server webwords-scala

functional-test-scala: functional-test ## Test scala implementation (requires running container)

clean-scala: ## Stop and remove Scala container and image
	-docker stop webwords-scala-server
	# -docker rm webwords-scala-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-scala

# Perl implementation
build-perl: ## Build Perl Docker image
	cd perl && docker build -t webwords-perl .

serve-perl: ## Run Perl container on port 31337
	docker run -d -p 31337:31337 --name webwords-perl-server webwords-perl

functional-test-perl: functional-test ## Test perl implementation (requires running container)

clean-perl: ## Stop and remove Perl container and image
	-docker stop webwords-perl-server
	# -docker rm webwords-perl-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-perl

# Lua implementation
build-lua: ## Build Lua Docker image
	cd lua && docker build -t webwords-lua .

serve-lua: ## Run Lua container on port 31337
	docker run -d -p 31337:31337 --name webwords-lua-server webwords-lua

functional-test-lua: functional-test ## Test lua implementation (requires running container)

clean-lua: ## Stop and remove Lua container and image
	-docker stop webwords-lua-server
	# -docker rm webwords-lua-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-lua

# Elixir implementation
build-elixir: ## Build Elixir Docker image
	cd elixir && docker build -t webwords-elixir .

serve-elixir: ## Run Elixir container on port 31337
	docker run -d -p 31337:31337 --name webwords-elixir-server webwords-elixir

functional-test-elixir: functional-test ## Test elixir implementation (requires running container)

clean-elixir: ## Stop and remove Elixir container and image
	-docker stop webwords-elixir-server
	# -docker rm webwords-elixir-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-elixir

# Dart implementation
build-dart: ## Build Dart Docker image
	cd dart && docker build -t webwords-dart .

serve-dart: ## Run Dart container on port 31337
	docker run -d -p 31337:31337 --name webwords-dart-server webwords-dart

functional-test-dart: functional-test ## Test dart implementation (requires running container)

clean-dart: ## Stop and remove Dart container and image
	-docker stop webwords-dart-server
	# -docker rm webwords-dart-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-dart

# R implementation
build-r: ## Build R Docker image
	cd r && docker build -t webwords-r .

serve-r: ## Run R container on port 31337
	docker run -d -p 31337:31337 --name webwords-r-server webwords-r

functional-test-r: functional-test ## Test r implementation (requires running container)

clean-r: ## Stop and remove R container and image
	-docker stop webwords-r-server
	# -docker rm webwords-r-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-r

# Haskell implementation
build-haskell: ## Build Haskell Docker image
	cd haskell && docker build -t webwords-haskell .

serve-haskell: ## Run Haskell container on port 31337
	docker run -d -p 31337:31337 --name webwords-haskell-server webwords-haskell

functional-test-haskell: functional-test ## Test haskell implementation (requires running container)

clean-haskell: ## Stop and remove Haskell container and image
	-docker stop webwords-haskell-server
	# -docker rm webwords-haskell-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-haskell

# OCaml implementation
build-ocaml: ## Build OCaml Docker image
	cd ocaml && docker build -t webwords-ocaml .

serve-ocaml: ## Run OCaml container on port 31337
	docker run -d -p 31337:31337 --name webwords-ocaml-server webwords-ocaml

functional-test-ocaml: functional-test ## Test ocaml implementation (requires running container)

clean-ocaml: ## Stop and remove OCaml container and image
	-docker stop webwords-ocaml-server
	# -docker rm webwords-ocaml-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-ocaml

# F# implementation
build-fsharp: ## Build F# Docker image
	cd fsharp && docker build -t webwords-fsharp .

serve-fsharp: ## Run F# container on port 31337
	docker run -d -p 31337:31337 --name webwords-fsharp-server webwords-fsharp

functional-test-fsharp: functional-test ## Test fsharp implementation (requires running container)

clean-fsharp: ## Stop and remove F# container and image
	-docker stop webwords-fsharp-server
	# -docker rm webwords-fsharp-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-fsharp

# Clojure implementation
build-clojure: ## Build Clojure Docker image
	cd clojure && docker build -t webwords-clojure .

serve-clojure: ## Run Clojure container on port 31337
	docker run -d -p 31337:31337 --name webwords-clojure-server webwords-clojure

functional-test-clojure: functional-test ## Test clojure implementation (requires running container)

clean-clojure: ## Stop and remove Clojure container and image
	-docker stop webwords-clojure-server
	# -docker rm webwords-clojure-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-clojure

# Crystal implementation
build-crystal: ## Build Crystal Docker image
	cd crystal && docker build -t webwords-crystal .

serve-crystal: ## Run Crystal container on port 31337
	docker run -d -p 31337:31337 --name webwords-crystal-server webwords-crystal

functional-test-crystal: functional-test ## Test crystal implementation (requires running container)

clean-crystal: ## Stop and remove Crystal container and image
	-docker stop webwords-crystal-server
	# -docker rm webwords-crystal-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-crystal

# Nim implementation
build-nim: ## Build Nim Docker image
	cd nim && docker build -t webwords-nim .

serve-nim: ## Run Nim container on port 31337
	docker run -d -p 31337:31337 --name webwords-nim-server webwords-nim

functional-test-nim: functional-test ## Test nim implementation (requires running container)

clean-nim: ## Stop and remove Nim container and image
	-docker stop webwords-nim-server
	# -docker rm webwords-nim-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-nim

# Erlang implementation
build-erlang: ## Build Erlang Docker image
	cd erlang && docker build -t webwords-erlang .

serve-erlang: ## Run Erlang container on port 31337
	docker run -d -p 31337:31337 --name webwords-erlang-server webwords-erlang

functional-test-erlang: functional-test ## Test erlang implementation (requires running container)

clean-erlang: ## Stop and remove Erlang container and image
	-docker stop webwords-erlang-server
	# -docker rm webwords-erlang-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-erlang

# Julia implementation
build-julia: ## Build Julia Docker image
	cd julia && docker build -t webwords-julia .

serve-julia: ## Run Julia container on port 31337
	docker run -d -p 31337:31337 --name webwords-julia-server webwords-julia

functional-test-julia: functional-test ## Test julia implementation (requires running container)

clean-julia: ## Stop and remove Julia container and image
	-docker stop webwords-julia-server
	# -docker rm webwords-julia-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-julia

# Deno implementation
build-deno: ## Build Deno Docker image
	cd deno && docker build -t webwords-deno .

serve-deno: ## Run Deno container on port 31337
	docker run -d -p 31337:31337 --name webwords-deno-server webwords-deno

functional-test-deno: functional-test ## Test deno implementation (requires running container)

clean-deno: ## Stop and remove Deno container and image
	-docker stop webwords-deno-server
	# -docker rm webwords-deno-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-deno

# Zig implementation
build-zig: ## Build Zig Docker image
	cd zig && docker build -t webwords-zig .

serve-zig: ## Run Zig container on port 31337
	docker run -d -p 31337:31337 --name webwords-zig-server webwords-zig

functional-test-zig: functional-test ## Test zig implementation (requires running container)

clean-zig: ## Stop and remove Zig container and image
	-docker stop webwords-zig-server
	# -docker rm webwords-zig-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-zig

# V implementation
build-v: ## Build V Docker image
	cd v && docker build -t webwords-v .

serve-v: ## Run V container on port 31337
	docker run -d -p 31337:31337 --name webwords-v-server webwords-v

functional-test-v: functional-test ## Test v implementation (requires running container)

clean-v: ## Stop and remove V container and image
	-docker stop webwords-v-server
	# -docker rm webwords-v-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-v

# Odin implementation
build-odin: ## Build Odin Docker image
	cd odin && docker build -t webwords-odin .

serve-odin: ## Run Odin container on port 31337
	docker run -d -p 31337:31337 --name webwords-odin-server webwords-odin

functional-test-odin: functional-test ## Test odin implementation (requires running container)

clean-odin: ## Stop and remove Odin container and image
	-docker stop webwords-odin-server
	# -docker rm webwords-odin-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-odin

# Bash implementation
build-bash: ## Build Bash Docker image
	cd bash && docker build -t webwords-bash .

serve-bash: ## Run Bash container on port 31337
	docker run -d -p 31337:31337 --name webwords-bash-server webwords-bash

functional-test-bash: functional-test ## Test bash implementation (requires running container)

clean-bash: ## Stop and remove Bash container and image
	-docker stop webwords-bash-server
	# -docker rm webwords-bash-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-bash

# COBOL implementation
build-cobol: ## Build COBOL Docker image
	cd cobol && docker build -t webwords-cobol .

serve-cobol: ## Run COBOL container on port 31337
	docker run -d -p 31337:31337 --name webwords-cobol-server webwords-cobol

functional-test-cobol: functional-test ## Test cobol implementation (requires running container)

clean-cobol: ## Stop and remove COBOL container and image
	-docker stop webwords-cobol-server
	# -docker rm webwords-cobol-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-cobol

# Fortran implementation
build-fortran: ## Build Fortran Docker image
	cd fortran && docker build -t webwords-fortran .

serve-fortran: ## Run Fortran container on port 31337
	docker run -d -p 31337:31337 --name webwords-fortran-server webwords-fortran

functional-test-fortran: functional-test ## Test fortran implementation (requires running container)

clean-fortran: ## Stop and remove Fortran container and image
	-docker stop webwords-fortran-server
	# -docker rm webwords-fortran-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-fortran

# Assembly implementation
build-assembly: ## Build Assembly Docker image
	cd assembly && docker build -t webwords-assembly .

serve-assembly: ## Run Assembly container on port 31337
	docker run -d -p 31337:31337 --name webwords-assembly-server webwords-assembly

functional-test-assembly: functional-test ## Test assembly implementation (requires running container)

clean-assembly: ## Stop and remove Assembly container and image
	-docker stop webwords-assembly-server
	# -docker rm webwords-assembly-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-assembly

# Prolog implementation
build-prolog: ## Build Prolog Docker image
	cd prolog && docker build -t webwords-prolog .

serve-prolog: ## Run Prolog container on port 31337
	docker run -d -p 31337:31337 --name webwords-prolog-server webwords-prolog

functional-test-prolog: functional-test ## Test prolog implementation (requires running container)

clean-prolog: ## Stop and remove Prolog container and image
	-docker stop webwords-prolog-server
	# -docker rm webwords-prolog-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-prolog

# MATLAB implementation
build-matlab: ## Build MATLAB Docker image
	cd matlab && docker build -t webwords-matlab .

serve-matlab: ## Run MATLAB container on port 31337
	docker run -d -p 31337:31337 --name webwords-matlab-server webwords-matlab

functional-test-matlab: functional-test ## Test matlab implementation (requires running container)

clean-matlab: ## Stop and remove MATLAB container and image
	-docker stop webwords-matlab-server
	# -docker rm webwords-matlab-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-matlab

# PowerShell implementation
build-powershell: ## Build PowerShell Docker image
	cd powershell && docker build -t webwords-powershell .

serve-powershell: ## Run PowerShell container on port 31337
	docker run -d -p 31337:31337 --name webwords-powershell-server webwords-powershell

functional-test-powershell: functional-test ## Test powershell implementation (requires running container)

clean-powershell: ## Stop and remove PowerShell container and image
	-docker stop webwords-powershell-server
	# -docker rm webwords-powershell-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-powershell

# Brainfuck implementation
build-brainfuck: ## Build Brainfuck Docker image
	cd brainfuck && docker build -t webwords-brainfuck .

serve-brainfuck: ## Run Brainfuck container on port 31337
	docker run -d -p 31337:31337 --name webwords-brainfuck-server webwords-brainfuck

functional-test-brainfuck: functional-test ## Test brainfuck implementation (requires running container)

clean-brainfuck: ## Stop and remove Brainfuck container and image
	-docker stop webwords-brainfuck-server
	# -docker rm webwords-brainfuck-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-brainfuck

# SQL implementation
build-sql: ## Build SQL Docker image
	cd sql && docker build -t webwords-sql .

serve-sql: ## Run SQL container on port 31337
	docker run -d -p 31337:31337 --name webwords-sql-server webwords-sql

functional-test-sql: functional-test ## Test sql implementation (requires running container)

clean-sql: ## Stop and remove SQL container and image
	-docker stop webwords-sql-server
	# -docker rm webwords-sql-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-sql

# VB.NET implementation
build-vbnet: ## Build VB.NET Docker image
	cd vbnet && docker build -t webwords-vbnet .

serve-vbnet: ## Run VB.NET container on port 31337
	docker run -d -p 31337:31337 --name webwords-vbnet-server webwords-vbnet

functional-test-vbnet: functional-test ## Test vbnet implementation (requires running container)

clean-vbnet: ## Stop and remove VB.NET container and image
	-docker stop webwords-vbnet-server
	# -docker rm webwords-vbnet-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-vbnet

# Tcl implementation
build-tcl: ## Build Tcl Docker image
	cd tcl && docker build -t webwords-tcl .

serve-tcl: ## Run Tcl container on port 31337
	docker run -d -p 31337:31337 --name webwords-tcl-server webwords-tcl

functional-test-tcl: functional-test ## Test tcl implementation (requires running container)

clean-tcl: ## Stop and remove Tcl container and image
	-docker stop webwords-tcl-server
	# -docker rm webwords-tcl-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-tcl

# AWK implementation
build-awk: ## Build AWK Docker image
	cd awk && docker build -t webwords-awk .

serve-awk: ## Run AWK container on port 31337
	docker run -d -p 31337:31337 --name webwords-awk-server webwords-awk

functional-test-awk: functional-test ## Test awk implementation (requires running container)

clean-awk: ## Stop and remove AWK container and image
	-docker stop webwords-awk-server
	# -docker rm webwords-awk-server  # Commented out to preserve Docker cache
	# -docker rmi webwords-awk

# Benchmarking targets
init-benchmarks: ## Initialize benchmarks.csv file with headers
	@if [ ! -f benchmarks.csv ]; then \
		echo "timestamp,language,build_time_seconds,startup_time_seconds,positive_response_time_seconds,negative_response_time_seconds,positive_result,negative_result,status" > benchmarks.csv; \
		echo "Initialized benchmarks.csv"; \
	else \
		echo "benchmarks.csv already exists"; \
	fi

benchmark: ## Run full benchmark for a specific language (usage: make benchmark LANG=python)
	@if [ -z "$(LANG)" ]; then \
		echo "Usage: make benchmark LANG=<language>"; \
		echo "Example: make benchmark LANG=python"; \
		exit 1; \
	fi
	@echo "Running full benchmark for $(LANG)..."
	@$(MAKE) init-benchmarks
	@$(MAKE) benchmark-workflow LANG=$(LANG)

benchmark-workflow: ## Internal target for benchmarking workflow
	@echo "=== Benchmarking $(LANG) ==="
	@timestamp="$$(date '+%Y-%m-%d %H:%M:%S')"; \
	echo "Starting benchmark at $$timestamp"; \
	\
	echo "Step 1: Building $(LANG)..."; \
	build_start=$$(date +%s.%N); \
	if $(MAKE) build-$(LANG) > /tmp/build-$(LANG).log 2>&1; then \
		build_end=$$(date +%s.%N); \
		build_time=$$(echo "$$build_end - $$build_start" | bc -l); \
		echo "Build completed in $${build_time}s"; \
		build_status="success"; \
	else \
		build_end=$$(date +%s.%N); \
		build_time=$$(echo "$$build_end - $$build_start" | bc -l); \
		echo "Build failed in $${build_time}s"; \
		build_status="build_failed"; \
		echo "$$timestamp,$(LANG),$$build_time,0,0,0,unknown,unknown,build_failed" >> benchmarks.csv; \
		exit 1; \
	fi; \
	\
	echo "Step 2: Starting $(LANG) server..."; \
	startup_start=$$(date +%s.%N); \
	if $(MAKE) serve-$(LANG) > /tmp/serve-$(LANG).log 2>&1; then \
		echo "Waiting for server startup..."; \
		sleep 3; \
		if curl -s --max-time 5 "http://localhost:31337/" > /dev/null 2>&1; then \
			startup_end=$$(date +%s.%N); \
			startup_time=$$(echo "$$startup_end - $$startup_start" | bc -l); \
			echo "Server started in $${startup_time}s"; \
			startup_status="success"; \
		else \
			startup_end=$$(date +%s.%N); \
			startup_time=$$(echo "$$startup_end - $$startup_start" | bc -l); \
			echo "Server startup failed (no response) in $${startup_time}s"; \
			startup_status="startup_failed"; \
			echo "$$timestamp,$(LANG),$$build_time,$$startup_time,0,0,unknown,unknown,startup_failed" >> benchmarks.csv; \
			$(MAKE) clean-$(LANG) > /dev/null 2>&1; \
			exit 1; \
		fi; \
	else \
		startup_end=$$(date +%s.%N); \
		startup_time=$$(echo "$$startup_end - $$startup_start" | bc -l); \
		echo "Server startup command failed in $${startup_time}s"; \
		startup_status="startup_failed"; \
		echo "$$timestamp,$(LANG),$$build_time,$$startup_time,0,0,unknown,unknown,startup_failed" >> benchmarks.csv; \
		exit 1; \
	fi; \
	\
	echo "Step 3: Testing positive case (potato)..."; \
	pos_start=$$(date +%s.%N); \
	pos_response=$$(curl -s --max-time 10 "http://localhost:31337/?keyword=potato&target=https://www.remarkbox.com" || echo "error"); \
	pos_end=$$(date +%s.%N); \
	pos_time=$$(echo "$$pos_end - $$pos_start" | bc -l); \
	echo "Positive test: $$pos_response ($$pos_time s)"; \
	\
	echo "Step 4: Testing negative case (lemon)..."; \
	neg_start=$$(date +%s.%N); \
	neg_response=$$(curl -s --max-time 10 "http://localhost:31337/?keyword=lemon&target=https://www.remarkbox.com" || echo "error"); \
	neg_end=$$(date +%s.%N); \
	neg_time=$$(echo "$$neg_end - $$neg_start" | bc -l); \
	echo "Negative test: $$neg_response ($$neg_time s)"; \
	\
	if [ "$$pos_response" = "true" ] && [ "$$neg_response" = "false" ]; then \
		overall_status="success"; \
		echo "✅ All tests passed!"; \
	else \
		overall_status="test_failed"; \
		echo "❌ Tests failed: expected true/false, got $$pos_response/$$neg_response"; \
	fi; \
	\
	echo "Step 5: Cleaning up..."; \
	$(MAKE) clean-$(LANG) > /dev/null 2>&1; \
	\
	echo "Step 6: Recording results..."; \
	echo "$$timestamp,$(LANG),$$build_time,$$startup_time,$$pos_time,$$neg_time,$$pos_response,$$neg_response,$$overall_status" >> benchmarks.csv; \
	echo "=== Benchmark complete for $(LANG) ==="

benchmark-all: ## Run benchmarks for all languages (WARNING: takes a long time)
	@echo "Running benchmarks for all 42 languages..."
	@$(MAKE) init-benchmarks
	@languages="go python js ruby php java csharp rust cpp kotlin swift scala perl lua elixir dart r haskell ocaml fsharp clojure crystal nim erlang julia deno zig v odin bash cobol fortran assembly prolog matlab powershell brainfuck sql vbnet tcl awk"; \
	for lang in $$languages; do \
		echo ""; \
		echo "🔄 Benchmarking $$lang..."; \
		if $(MAKE) benchmark LANG=$$lang; then \
			echo "✅ $$lang benchmark completed"; \
		else \
			echo "❌ $$lang benchmark failed"; \
		fi; \
		echo ""; \
	done; \
	echo "🏁 All benchmarks complete!"

benchmark-report: ## Generate benchmark analysis report
	@if [ ! -f benchmarks.csv ]; then \
		echo "No benchmarks.csv file found. Run benchmarks first."; \
		exit 1; \
	fi
	@echo "=== WebWords Benchmark Report ==="
	@echo "Generated at: $$(date '+%Y-%m-%d %H:%M:%S')"
	@echo ""
	@echo "Total benchmark runs: $$(tail -n +2 benchmarks.csv | wc -l)"
	@echo ""
	@echo "Success rate by language:"
	@tail -n +2 benchmarks.csv | awk -F, '{print $$2, $$9}' | sort | uniq -c | awk '{printf "  %-12s: %s (%d runs)\n", $$2, $$3, $$1}'
	@echo ""
	@echo "Average build times (successful builds only):"
	@tail -n +2 benchmarks.csv | awk -F, '$$9=="success" {sum[$$2]+=$$3; count[$$2]++} END {for (lang in sum) printf "  %-12s: %.2f seconds\n", lang, sum[lang]/count[lang]}' | sort -k3 -n
	@echo ""
	@echo "Average response times (successful tests only):"
	@tail -n +2 benchmarks.csv | awk -F, '$$9=="success" {sum[$$2]+=($$5+$$6)/2; count[$$2]++} END {for (lang in sum) printf "  %-12s: %.3f seconds\n", lang, sum[lang]/count[lang]}' | sort -k3 -n
	@echo ""
	@echo "Fastest languages (by total time: build + startup + avg response):"
	@tail -n +2 benchmarks.csv | awk -F, '$$9=="success" {total[$$2]+=($$3+$$4+($$5+$$6)/2); count[$$2]++} END {for (lang in total) printf "  %-12s: %.2f seconds\n", lang, total[lang]/count[lang]}' | sort -k3 -n | head -10

view-benchmarks: ## View recent benchmark results in table format
	@if [ ! -f benchmarks.csv ]; then \
		echo "No benchmarks.csv file found. Run benchmarks first."; \
		exit 1; \
	fi
	@echo "Recent benchmark results (last 20 runs):"
	@tail -n 21 benchmarks.csv | column -t -s ','

# Development utilities
test-workflow: ## Example workflow: build, serve, and test a language (usage: make test-workflow LANG=python)
	@if [ -z "$(LANG)" ]; then \
		echo "Usage: make test-workflow LANG=<language>"; \
		echo "Example: make test-workflow LANG=python"; \
		exit 1; \
	fi
	@echo "Running full workflow for $(LANG)..."
	make build-$(LANG)
	make serve-$(LANG)
	sleep 3
	make functional-test-$(LANG)
	make clean-$(LANG)

status: ## Show running WebWords containers
	@echo "Running WebWords containers:"
	@docker ps --filter "name=webwords-" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

system-info: ## Show system information for testing performance
	@echo "System Information for WebWords Testing:"
	@echo "========================================"
	@echo "CPU cores available: $$(nproc)"
	@echo "Memory available: $$(free -h | awk '/^Mem:/ {print $$2}')"
	@echo "Docker images built: $$(docker images --filter 'reference=webwords-*' --format '{{.Repository}}' | wc -l)"
	@echo ""
	@echo "Recommended concurrent job counts:"
	@echo "  Conservative (half cores): $$((($$(nproc) + 1) / 2)) jobs"
	@echo "  Aggressive (all cores): $$(nproc) jobs"
	@echo "  Safe (single): 1 job"
	@echo ""
	@echo "Quick test commands:"
	@echo "  make test-all-conservative  # Use $$((($$(nproc) + 1) / 2)) jobs"
	@echo "  make test-all              # Use $$(nproc) jobs"

cleanup-all: ## Stop and remove all WebWords containers (but keep images)
	@echo "Stopping and removing all WebWords containers..."
	@docker ps -q --filter "name=webwords-" | xargs -r docker stop
	# @docker ps -aq --filter "name=webwords-" | xargs -r docker rm  # Commented out to preserve Docker cache

prune: ## Remove all unused Docker resources
	docker system prune -f

# Quality assurance
lint-dockerfile: ## Lint all Dockerfiles using hadolint (requires hadolint installed)
	@echo "Linting Dockerfiles..."
	@find . -name "Dockerfile" -exec echo "Checking {}" \; -exec hadolint {} \;

# Analysis targets
images-report: ## Show all WebWords Docker images and their sizes
	@echo "WebWords Docker Images:"
	@docker images --filter "reference=webwords-*" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"

base-images-report: ## Analyze base images used across all Dockerfiles
	@echo "Base Images Analysis:"
	@echo "====================="
	@find . -name "Dockerfile" -exec sh -c 'echo -n "{}: "; head -1 {} | cut -d" " -f2' \; | sort | uniq -c | sort -nr