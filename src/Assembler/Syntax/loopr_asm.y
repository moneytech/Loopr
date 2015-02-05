%{
#include <stdio.h>
#include "LBS.h"
#include "MEM.h"
#include "Assembler.h"
#define YYDEBUG 1
%}
%union {
	char			*identifier;
	Bytecode		*bytecode;
    Statement		*statement;
	Constant		*constant;
	StatementList	*statement_list;
}
%token COLON COMMA LB RB LP RP DOT
	   NEXT_LINE NULL_LITERAL
%token <identifier>		IDENTIFIER
%token <constant>		CHAR_LITERAL
%token <constant>		DIGIT_LITERAL
%token <constant>		FLOAT_LITERAL
%token <constant>		STRING_LITERAL
%token <constant>		TRUE_C FALSE_C

%type <identifier> label
%type <bytecode> dot_bytecode compiler_ref
%type <constant> constant constant_list constant_list_opt
%type <statement> statement
%type <statement_list> statement_list
%%
/*************** Frame ***************/
translation_unit
	: /* NULL */
	| translation_unit top_level_unit translation_unit
	;
top_level_unit
	: next_line_list_opt statement_list next_line_list_opt
	{
		Asm_Compiler *current_compiler;
		current_compiler = Asm_get_current_compiler();
		if (current_compiler->top_level) {
			Asm_cat_statement_list(current_compiler->top_level,
								   $2);
		} else {
			current_compiler->top_level = $2;
		}
	}
	;

/*************** Detail Syntax ***************/
dot_bytecode
	: IDENTIFIER
	{
		$$ = Asm_create_bytecode($1, 0, LPR_False);
	}
	| DIGIT_LITERAL
	{
		$$ = Asm_create_bytecode(NULL, $1->u.byte_value, LPR_True);
	}
	| dot_bytecode DOT IDENTIFIER
	{
		$$ = Asm_chain_bytecode($1, $3, 0, LPR_False);
	}
	| dot_bytecode DOT DIGIT_LITERAL
	{
		$$ = Asm_chain_bytecode($1, NULL, $3->u.byte_value, LPR_True);
	}
	;
compiler_ref
	: DOT IDENTIFIER
	{
		$$ = Asm_chain_bytecode(Asm_create_bytecode(NULL, 0, LPR_False),
								$2, 0, LPR_False);
	}
	| DOT DIGIT_LITERAL
	{
		$$ = Asm_chain_bytecode(Asm_create_bytecode(NULL, 0, LPR_False),
								NULL, $2->u.byte_value, LPR_True);
	}
	;
constant
	: CHAR_LITERAL
	| DIGIT_LITERAL
	| FLOAT_LITERAL
	| STRING_LITERAL
	| TRUE_C
	| FALSE_C
	| IDENTIFIER
	{
		Constant *constant = Asm_alloc_constant(CONST_LABEL);
		constant->u.string_value = $1;
		$$ = constant;
	}
	;
constant_list
	: constant
	| constant_list COMMA constant
	{
		$$ = Asm_chain_constant($1, $3);
	}
	;
constant_list_opt
	: /* NULL */
	{
		$$ = NULL;
	}
	| constant_list
	;
next_line_list
	: NEXT_LINE
	| next_line_list NEXT_LINE
	;
next_line_list_opt
	: /* NULL */
	| next_line_list
	;
label
	: IDENTIFIER COLON next_line_list_opt
	{
		$$ = $1;
	}
	;
statement
	: label
	{
		$$ = Asm_create_statement($1, NULL, NULL);
	}
	| dot_bytecode constant_list_opt NEXT_LINE
	{
		$$ = Asm_create_statement(NULL, $1, $2);
	}
	| compiler_ref constant_list_opt NEXT_LINE
	{	
		$$ = Asm_create_statement(NULL, $1, $2);
	}
	;
statement_list
	: statement next_line_list_opt
	{
		$$ = Asm_create_statement_list($1);
	}
	| statement next_line_list_opt statement_list
	{
		$$ = Asm_chain_statement_list($1, $3);
	}
	;
%%