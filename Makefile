SRC_DIR = src
BUILD_DIR = build
OUTPUT = ft_turing

MODULES = types parsing_and_validation execute_machine ft_turing
SRC_FILES = $(addprefix $(SRC_DIR)/,$(addsuffix .ml,$(MODULES)))
OBJ_FILES = $(addprefix $(BUILD_DIR)/,$(addsuffix .cmx,$(MODULES)))

all: $(OUTPUT)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Compile each .ml file into .cmx and .cmi
$(BUILD_DIR)/%.cmx: $(SRC_DIR)/%.ml | $(BUILD_DIR)
	opam exec -- ocamlfind ocamlopt -package yojson -I $(BUILD_DIR) -c -o $@ $<

# Link all object files to make the executable
$(OUTPUT): $(OBJ_FILES)
	opam exec -- ocamlfind ocamlopt -package yojson -linkpkg -I $(BUILD_DIR) -o $@ $(OBJ_FILES)

clean:
	rm -f $(BUILD_DIR)/*.cmx $(BUILD_DIR)/*.o $(BUILD_DIR)/*.cmi tests/*.cmi tests/*.cmo 

fclean: clean
	rm -rf $(BUILD_DIR) $(OUTPUT) tests/test_runner

test: $(BUILD_DIR)/parsing_and_validation.cmo $(BUILD_DIR)/types.cmo
	opam exec -- ocamlfind ocamlc -package yojson -linkpkg -I build build/parsing_and_validation.cmo build/types.cmo tests/parsing_and_validation_test.ml -o tests/test_runner
	./tests/test_runner

$(BUILD_DIR)/%.cmo: $(SRC_DIR)/%.ml | $(BUILD_DIR)
	opam exec -- ocamlfind ocamlc -package yojson -I $(BUILD_DIR) -c -o $@ $<

re: fclean all

format:
	@echo "Formatting OCaml files..."
	@for file in $(SRC_FILES); do \
		echo "Formatting $$file"; \
		opam exec -- ocamlformat --inplace $$file; \
	done

# Check if files are properly formatted (useful for CI)
format-check:
	@echo "Checking OCaml files formatting..."
	@for file in $(SRC_FILES); do \
		echo "Checking $$file"; \
		opam exec -- ocamlformat --check $$file; \
	done

.PHONY: all clean fclean re format format-check

# TODO: install opam to run on evaluator's machine