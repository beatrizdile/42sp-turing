SRC_DIR = src
BUILD_DIR = build
OUTPUT = ft_turing

MODULES = types validation parsing print execute_machine ft_turing
SRC_FILES = $(addprefix $(SRC_DIR)/,$(addsuffix .ml,$(MODULES)))
OBJ_FILES = $(addprefix $(BUILD_DIR)/,$(addsuffix .cmx,$(MODULES)))

TEST_MODULES = $(filter-out ft_turing,$(MODULES))
TEST_SRC_FILES = $(addprefix $(SRC_DIR)/,$(addsuffix .ml,$(TEST_MODULES)))
TEST_OBJ_FILES = $(addprefix $(BUILD_DIR)/,$(addsuffix .cmo,$(TEST_MODULES)))
TEST_RUNNER_SRC = tests/parsing_and_validation_test.ml

all: $(OUTPUT)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/%.cmx: $(SRC_DIR)/%.ml | $(BUILD_DIR)
	opam exec -- ocamlfind ocamlopt -package yojson -I $(BUILD_DIR) -c -o $@ $<

$(OUTPUT): $(OBJ_FILES)
	opam exec -- ocamlfind ocamlopt -package yojson -linkpkg -I $(BUILD_DIR) -o $@ $(OBJ_FILES)

$(BUILD_DIR)/%.cmo: $(SRC_DIR)/%.ml | $(BUILD_DIR)
	opam exec -- ocamlfind ocamlc -package yojson -I $(BUILD_DIR) -c -o $@ $<

clean:
	rm -f $(BUILD_DIR)/*.cmx $(BUILD_DIR)/*.o $(BUILD_DIR)/*.cmi tests/*.cmi tests/*.cmo 

fclean: clean
	rm -rf $(BUILD_DIR) $(OUTPUT) tests/test_runner

test: $(TEST_OBJ_FILES)
	opam exec -- ocamlfind ocamlc -package yojson -linkpkg -I $(BUILD_DIR) $(TEST_OBJ_FILES) $(TEST_RUNNER_SRC) -o tests/test_runner
	./tests/test_runner

re: fclean all

format:
	@echo "Formatting OCaml files..."
	@for file in $(SRC_FILES); do \
		echo "Formatting $$file"; \
		opam exec -- ocamlformat --inplace $$file; \
	done

format-check:
	@echo "Checking OCaml files formatting..."
	@for file in $(SRC_FILES); do \
		echo "Checking $$file"; \
		opam exec -- ocamlformat --check $$file; \
	done

.PHONY: all clean fclean re format format-check

# TODO: install opam to run on evaluator's machine
