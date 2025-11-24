# 3-Address Code Generator for BcsMain Grammar

This repository contains a simple 3-address code generator for the "BcsMain" language (grammar implemented in `IR.y`). The project uses a Bison parser (`IR.y`) and a Flex lexer (`IR.l`) to parse input programs and emit three-address code into `result.txt`.

**What this repo does:**
- **Parses** a tiny language whose top-level construct is `BcsMain`.
- **Generates** three-address code for assignments and arithmetic expressions (addition and multiplication) using temporary variables `v0, v1, ...`.

**Output file:** The generated 3-address code is written to `result.txt` by the parser executable.

**Note about the lexer include:** `IR.l` should include `IR.tab.h` (the header produced by `bison -d IR.y`). The instructions below assume `IR.l` includes `IR.tab.h`. If you prefer a custom Bison output base, run Bison with `-b <base>` and adjust the include in `IR.l` accordingly.

**Accepted grammar (BNF-style)**

Start symbol: `program`

program     ::= MAINFN "{" declList stmtGroup "}"

declList    ::= declList declStmt
							| declStmt

declStmt    ::= dataType IDENT ";"

dataType    ::= "int"
							| "bool"

stmtGroup   ::= stmtGroup ";" stmtBlock
							| stmtBlock

stmtBlock   ::= IDENT "=" expr

expr        ::= expr "+" term
							| term

term        ::= term "*" factor
							| factor

factor      ::= IDENT
							| NUMBER

Notes:
- Identifiers are tokenized as `IDENT`.
- Integer constants are tokenized as `NUMBER`.
- Only assignment statements and arithmetic expressions are supported for code generation in the provided grammar.

**Token summary (as defined in `IR.l`)**
- `MAINFN`     : "BcsMain"
- `INT_TYPE`   : "int"
- `BOOL_TYPE`  : "bool"
- `LBRACE_SYM` : "{"
- `RBRACE_SYM` : "}"
- `LPAREN_SYM` : "("
- `RPAREN_SYM` : ")"
- `SEMI_SYM`   : ";"
- `ASSIGN_OP`  : "="
- `ADD_OP`     : "+"
- `MUL_OP`     : "*"
- `REL_OP`     : relational operators like `<`, `>`, `<=`, `>=`, `==`, `!=` (not used by generator rules shown)
- `IDENT`      : identifier (letters followed by letters/digits)
- `NUMBER`     : integer constant

**How to compile and get an executable**

Follow these steps (recommended):

```bash
# Generate parser (creates IR.tab.c and IR.tab.h)
bison -d IR.y

# Generate lexer (IR.l should include IR.tab.h)
flex IR.l

# Compile and link (links the flex library). Produces executable named `ir`
gcc -o ir IR.tab.c lex.yy.c -lfl
```

Troubleshooting notes:
- On some systems the flex library is `-ll` instead of `-lfl`. If the previous link fails, try `-ll`.
- If `bison` produces files named `y.tab.c`/`y.tab.h` (rare with modern bison), adapt the compile command accordingly.
- Ensure `flex` and `bison` are installed (e.g., `brew install flex bison` on macOS if missing).

**Run the parser**

After building the `ir` executable, run it and supply the source on stdin or via a file redirect. The parser writes three-address code to `result.txt`.

```bash
# Interactive / stdin
./ir < program.src

# Or run and provide input interactively (if your parser reads from stdin)
./ir

# Check the generated 3-address code
cat result.txt
```

**Example input**

```
BcsMain {
	int a;
	int b;
	a = 3 + 4 * 5;
}
```

Expected portion of generated `result.txt` (example):

```
v0 = 4 * 5
v1 = 3 + v0
a = v1
```

If you want, I can also:
- update `IR.l` to include `IR.tab.h` instead of `CS04_3.tab.h` and provide a small test file and a script to build and run; or
- add a Makefile to automate the build steps.

---
Updated README to include grammar and build/run instructions.
