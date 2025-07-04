SRC_DIR = src
BUILD_DIR = build
OUTPUT = ft_turing

SRC_FILES = $(SRC_DIR)/parsing_json.ml $(SRC_DIR)/ft_turing.ml
OBJ_FILES = $(BUILD_DIR)/parsing_json.cmx $(BUILD_DIR)/ft_turing.cmx

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
	rm -f $(BUILD_DIR)/*.cmx $(BUILD_DIR)/*.o $(BUILD_DIR)/*.cmi

fclean: clean
	rm -rf $(BUILD_DIR) $(OUTPUT)

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
