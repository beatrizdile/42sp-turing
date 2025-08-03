SRC_DIR = src
BUILD_DIR = build
OUTPUT = ft_turing

MODULES = types validation parsing print execute_machine ft_turing
SRC_FILES = $(addprefix $(SRC_DIR)/,$(addsuffix .ml,$(MODULES)))
OBJ_FILES = $(addprefix $(BUILD_DIR)/,$(addsuffix .cmx,$(MODULES)))

TEST_DIR = tests
TEST_FILES = $(filter-out ft_turing,$(MODULES)) test_utils parsing_and_validation_test
TEST_OBJ_FILES = $(addprefix $(BUILD_DIR)/,$(addsuffix .cmx,$(TEST_FILES)))

all: check-deps $(OUTPUT)

check-deps:
	@echo "Checking dependencies..."
	@if ! command -v ocaml >/dev/null 2>&1; then \
		echo "OCaml not found. Installing..."; \
		if command -v apt-get >/dev/null 2>&1; then \
			sudo apt-get update && sudo apt-get install -y ocaml opam; \
		elif command -v yum >/dev/null 2>&1; then \
			sudo yum install -y ocaml opam; \
		elif command -v dnf >/dev/null 2>&1; then \
			sudo dnf install -y ocaml opam; \
		elif command -v brew >/dev/null 2>&1; then \
			brew install ocaml opam; \
		elif command -v pacman >/dev/null 2>&1; then \
			sudo pacman -S ocaml opam; \
		elif command -v zypper >/dev/null 2>&1; then \
			sudo zypper install ocaml opam; \
		else \
			echo "Package manager not found. Run 'make install-deps' for manual installation."; \
			exit 1; \
		fi; \
	fi
	@if ! command -v opam >/dev/null 2>&1; then \
		echo "opam not found. Installing..."; \
		if command -v apt-get >/dev/null 2>&1; then \
			sudo apt-get install -y opam; \
		elif command -v yum >/dev/null 2>&1; then \
			sudo yum install -y opam; \
		elif command -v dnf >/dev/null 2>&1; then \
			sudo dnf install -y opam; \
		elif command -v brew >/dev/null 2>&1; then \
			brew install opam; \
		elif command -v pacman >/dev/null 2>&1; then \
			sudo pacman -S opam; \
		elif command -v zypper >/dev/null 2>&1; then \
			sudo zypper install opam; \
		else \
			echo "Package manager not found. Run 'make install-deps' for manual installation."; \
			exit 1; \
		fi; \
	fi
	@if [ ! -d ~/.opam ]; then \
		echo "Initializing opam..."; \
		opam init -y --disable-sandboxing || opam init -y; \
		eval $$(opam env); \
	fi
	@echo "Ensuring opam environment is set..."
	@eval $$(opam env)
	@echo "Checking OCaml packages..."
	@if ! opam list yojson 2>/dev/null | grep -q yojson; then \
		echo "Installing yojson..."; \
		eval $$(opam env) && opam install -y yojson; \
	fi
	@if ! opam list ocamlfind 2>/dev/null | grep -q ocamlfind; then \
		echo "Installing ocamlfind..."; \
		eval $$(opam env) && opam install -y ocamlfind; \
	fi
	@if ! opam list ocamlformat 2>/dev/null | grep -q ocamlformat; then \
		echo "Installing ocamlformat..."; \
		eval $$(opam env) && opam install -y ocamlformat; \
	fi
	@echo "All dependencies are installed!"

install-deps:
	@echo "Manual dependency installation..."
	@echo "This will install OCaml and required packages."
	@echo "Please ensure you have curl or wget installed."
	@if ! command -v ocaml >/dev/null 2>&1 || ! command -v opam >/dev/null 2>&1; then \
		echo "Installing opam..."; \
		sh <(curl -sL https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh) || \
		bash -c "sh <(wget -O - https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh)"; \
	fi
	@if [ ! -d ~/.opam ]; then \
		echo "Initializing opam..."; \
		opam init -y --disable-sandboxing; \
	fi
	@eval $$(opam env) && opam install -y yojson ocamlfind ocamlformat
	@echo "Manual installation completed!"

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(OUTPUT): $(OBJ_FILES)
	opam exec -- ocamlfind ocamlopt -package yojson -linkpkg -I $(BUILD_DIR) -o $@ $(OBJ_FILES)

$(BUILD_DIR)/%.cmx: $(SRC_DIR)/%.ml | $(BUILD_DIR)
	opam exec -- ocamlfind ocamlopt -package yojson -I $(BUILD_DIR) -c -o $@ $<

$(BUILD_DIR)/%.cmx: $(TEST_DIR)/%.ml | $(BUILD_DIR)
	opam exec -- ocamlfind ocamlopt -package yojson -I $(BUILD_DIR) -c -o $@ $<

$(BUILD_DIR)/%.cmo: $(SRC_DIR)/%.ml | $(BUILD_DIR)
	opam exec -- ocamlfind ocamlc -package yojson -I $(BUILD_DIR) -c -o $@ $<

$(BUILD_DIR)/%.cmo: $(TEST_DIR)/%.ml | $(BUILD_DIR)
	opam exec -- ocamlfind ocamlc -package yojson -I $(BUILD_DIR) -c -o $@ $<

clean:
	rm -f $(BUILD_DIR)/*.cmi $(BUILD_DIR)/*.cmo $(BUILD_DIR)/*.cmx $(BUILD_DIR)/*.o

fclean: clean
	rm -rf $(BUILD_DIR) $(OUTPUT) tests/test_runner

test: check-deps $(TEST_OBJ_FILES)
	opam exec -- ocamlfind ocamlopt -package yojson -linkpkg -I $(BUILD_DIR) $(TEST_OBJ_FILES) -o tests/test_runner
	./tests/test_runner

re: fclean all

format: check-deps
	@echo "Formatting OCaml files..."
	@for file in $(SRC_FILES); do \
		echo "Formatting $$file"; \
		opam exec -- ocamlformat --inplace $$file; \
	done

format-check: check-deps
	@echo "Checking OCaml files formatting..."
	@for file in $(SRC_FILES); do \
		echo "Checking $$file"; \
		opam exec -- ocamlformat --check $$file; \
	done

run: all
	@echo "Running ft_turing with default test..."
	./$(OUTPUT) res/unary_sub.json 111-11=

run-all: all
	@echo "==============================================="
	@echo "Testing all Turing machines with various inputs"
	@echo "==============================================="
	@echo "\n\n1. Testing unary subtraction machine:"
	@echo "-----------------------------------------------"
	-./$(OUTPUT) res/unary_sub.json 111-11=
	@echo ""
	-./$(OUTPUT) res/unary_sub.json 1111-11=
	@echo ""
	-./$(OUTPUT) res/unary_sub.json 11111-111=
	@echo ""
	@echo "2. Testing unary addition machine:"
	@echo "-----------------------------------------------"
	-./$(OUTPUT) res/unary_add.json 11+111=
	@echo ""
	-./$(OUTPUT) res/unary_add.json 1+1=
	@echo ""
	-./$(OUTPUT) res/unary_add.json 1111+11=
	@echo ""
	@echo "3. Testing minimal unary add machine:"
	@echo "-----------------------------------------------"
	-./$(OUTPUT) res/min_unary_add.json 11+11=
	@echo ""
	-./$(OUTPUT) res/min_unary_add.json 1+111=
	@echo ""
	@echo "4. Testing palindrome machine:"
	@echo "-----------------------------------------------"
	-./$(OUTPUT) res/palindrome.json 101
	@echo ""
	-./$(OUTPUT) res/palindrome.json 1111
	@echo ""
	-./$(OUTPUT) res/palindrome.json 1010
	@echo ""
	-./$(OUTPUT) res/palindrome.json 11011
	@echo ""
	-./$(OUTPUT) res/palindrome.json 1
	@echo ""
	-./$(OUTPUT) res/palindrome.json 0
	@echo ""
	@echo "5. Testing even/odd machine:"
	@echo "-----------------------------------------------"
	-./$(OUTPUT) res/even_odd.json 0
	@echo ""
	-./$(OUTPUT) res/even_odd.json 000
	@echo ""
	-./$(OUTPUT) res/even_odd.json 0000
	@echo ""
	@echo "6. Testing zero-one word machine:"
	@echo "-----------------------------------------------"
	-./$(OUTPUT) res/zero_one_word.json 0
	@echo ""
	-./$(OUTPUT) res/zero_one_word.json 1
	@echo ""
	-./$(OUTPUT) res/zero_one_word.json 001
	@echo ""
	-./$(OUTPUT) res/zero_one_word.json 1100
	@echo ""
	@echo "==============================================="
	@echo "              All tests completed!"
	@echo "==============================================="

run-quick: all
	@echo "Quick test suite (one test per machine):"
	@echo "========================================"
	-./$(OUTPUT) res/unary_sub.json 111-11=
	-./$(OUTPUT) res/unary_add.json 11+111=
	-./$(OUTPUT) res/palindrome.json 101
	-./$(OUTPUT) res/even_odd.json 0000
	-./$(OUTPUT) res/zero_one_word.json 00111
	@echo "========================================"

help:
	@echo "Available targets:"
	@echo "  all           - Build the project (includes dependency check)"
	@echo "  clean         - Remove object files"
	@echo "  fclean        - Remove all generated files"
	@echo "  re            - Clean and rebuild"
	@echo "  test          - Run unit tests (includes dependency check)"
	@echo "  run           - Build and run with default parameters"
	@echo "  run-all       - Run comprehensive tests on all machines with various inputs"
	@echo "  run-quick     - Run quick test suite (one test per machine)"
	@echo "  format        - Format OCaml source files"
	@echo "  format-check  - Check OCaml files formatting"
	@echo "  check-deps    - Check and install missing dependencies"
	@echo "  install-deps  - Manual dependency installation"
	@echo "  help          - Show this help message"

.PHONY: all clean fclean re format format-check check-deps install-deps test run run-all run-quick help

# TODO: install opam to run on evaluator's machine
# TODO: insert dots at the beginning and end
# TODO: If for some reason the machine is blocked, you
# must detect it and inform the user of your program of what happened.
