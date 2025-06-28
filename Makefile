SRC = ft_turing.ml
OUTPUT = ft_turing
BUILD_DIR = build
OBJ = $(BUILD_DIR)/ft_turing.cmx

all: $(OUTPUT)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(OBJ): $(SRC) | $(BUILD_DIR)
	opam exec -- ocamlfind ocamlopt -package yojson -c -o $(OBJ) $(SRC)

$(OUTPUT): $(OBJ)
	opam exec -- ocamlfind ocamlopt -package yojson -linkpkg -o $(OUTPUT) $(OBJ)

clean:
	rm -f $(BUILD_DIR)/*.cmx $(BUILD_DIR)/*.o $(BUILD_DIR)/*.cmi

fclean: clean
	rm -rf $(BUILD_DIR) $(OUTPUT)

re: fclean all

.PHONY: all clean fclean re

# TODO: install opam to run on evaluator's machine