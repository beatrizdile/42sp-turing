SRC_DIR = src
BUILD_DIR = build
OUTPUT = ft_turing

MODULES = types validation parsing print execute_machine ft_turing
SRC_FILES = $(addprefix $(SRC_DIR)/,$(addsuffix .ml,$(MODULES)))
OBJ_FILES = $(addprefix $(BUILD_DIR)/,$(addsuffix .cmx,$(MODULES)))

TEST_DIR = tests
TEST_FILES = $(filter-out ft_turing,$(MODULES)) test_utils parsing_and_validation_test
TEST_OBJ_FILES = $(addprefix $(BUILD_DIR)/,$(addsuffix .cmx,$(TEST_FILES)))

all: $(OUTPUT)

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

test: $(TEST_OBJ_FILES)
	opam exec -- ocamlfind ocamlopt -package yojson -linkpkg -I $(BUILD_DIR) $(TEST_OBJ_FILES) -o tests/test_runner
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

run: all
	./$(OUTPUT) res/unary_sub.json 111-11=

.PHONY: all clean fclean re format format-check

# TODO: install opam to run on evaluator's machine
# TODO: insert dots at the beginning and end
# TODO: If for some reason the machine is blocked, you
# must detect it and inform the user of your program of what happened.