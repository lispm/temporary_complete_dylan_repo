#include "../compat/std-c.h"

#include "mindycomp.h"
#include "feature.h"
#include "lexer.h"
#include "src.h"
#include "parser-tab.h"
#include "sym.h"


static struct feature {
    struct symbol *symbol;
    struct feature *next;
} *Features = NULL;

#ifndef INITIAL_FEATURES
#define INITIAL_FEATURES "mindy"
#endif

static char *InitialFeatures[] = {INITIAL_FEATURES, NULL};

static boolean feature_present(struct symbol *sym)
{
    struct feature *feature;

    for (feature = Features; feature != NULL; feature = feature->next)
	if (feature->symbol == sym)
	    return TRUE;

    return FALSE;
}

static struct state {
    boolean active;
    boolean do_else;
    boolean seen_else;
    struct state *old_state;
} *State = NULL;

static void push_state(boolean active, boolean do_else)
{
    struct state *new = malloc(sizeof(struct state));

    new->active = active;
    new->do_else = do_else;
    new->seen_else = FALSE;
    new->old_state = State;
    State = new;
}

static void pop_state(void)
{
    struct state *old = State->old_state;

    free(State);

    State = old;
}
    

static int yytoken = 0;

static void new_token(void)
{
    free(yylval.token);
    yytoken = internal_yylex();
}


static void parse_error(void)
{
    if (yylval.token)
	error(line_count,
	      "syntax error in feature condition at or before ``%s''",
	      yylval.token->chars);
    else
	error(line_count, "syntax error in feature condition at end-of-file");
    exit(1);
}

static boolean parse_feature_expr(void);

static boolean parse_feature_word(void)
{
    struct symbol *sym;

    if (yylval.token->chars[0] == '\\')
	sym = symbol(yylval.token->chars + 1);
    else
	sym = symbol(yylval.token->chars);

    new_token();

    return feature_present(sym);
}

static boolean parse_feature_term(void)
{
    switch (yytoken) {
      case LPAREN:
	return parse_feature_expr();

      case TILDE:
	new_token();
	return !parse_feature_term();

	/* All the various things that look like words. */
      case ABSTRACT: case ABOVE: case DBEGIN: case BELOW: case BLOCK:
      case BY: case CASE: case CLASS: case CLEANUP: case CONCRETE:
      case CONSTANT: case DEFINE: case ELSE: case ELSEIF: case END:
      case EXCEPTION: case FINALLY: case FOR: case FREE: case FROM:
      case GENERIC: case HANDLER: case IF: case IN: case INHERITED:
      case INSTANCE: case KEYED_BY: case KEYWORD_RESERVED_WORD:
      case LET: case LOCAL: case METHOD: case OPEN: case OTHERWISE:
      case PRIMARY: case REQUIRED: case SEAL: case SEALED: case SELECT:
      case SLOT: case SUBCLASS: case THEN: case TO: case UNLESS:
      case UNTIL: case VARIABLE: case VIRTUAL: case WHILE: case MODULE:
      case LIBRARY: case EXPORT: case CREATE: case USE: case ALL:
      case SYMBOL:
	return parse_feature_word();

      default:
	parse_error();
    }
}

static boolean parse_feature_expr(void)
{
    int res;

    /* Consume the left paren. */
    new_token();

    res = parse_feature_term();

    while (1) {
	switch (yytoken) {
	  case RPAREN:
	    /* Consume the right paren and return. */
	    new_token();
	    return res;

	  case BINARY_OPERATOR:
	    switch (yylval.token->chars[0]) {
	      case '&':
		new_token();
		if (!parse_feature_term())
		    res = FALSE;
		break;

	      case '|':
		new_token();
		if (parse_feature_term())
		    res = TRUE;
		break;

	      default:
		parse_error();
	    }
	    break;

	  default:
	    parse_error();
	}
    }
}

static boolean parse_conditional(void)
{
    /* Consume the #if or #elseif token */
    new_token();

    /* If the next token isn't a right paren, something is wrong. */
    if (yytoken != LPAREN)
	parse_error();

    return parse_feature_expr();
}

int yylex(void)
{
    boolean cond;

    yytoken = internal_yylex();

    while (1) {
	switch (yytoken) {
	  case FEATURE_IF:
	    cond = parse_conditional();
	    if (State == NULL || State->active)
		push_state(cond, !cond);
	    else
		push_state(FALSE, FALSE);
	    break;

	  case FEATURE_ELSE_IF:
	    if (State == NULL) {
		error(line_count,
		      "#elseif with no matching #if, treating as #if");
		cond = parse_conditional();
		push_state(cond, !cond);
	    }
	    else if (State->seen_else) {
		error(line_count, "#elseif after #else in one #if");
		State->active = FALSE;
	    }
	    else if (parse_conditional()) {
		State->active = State->do_else;
		State->do_else = FALSE;
	    }
	    else
		State->active = FALSE;
	    break;

	  case FEATURE_ELSE:
	    if (State == NULL)
		error(line_count, "#else with no matching #if, ignoring");
	    else if (State->seen_else) {
		error(line_count, "#else after #else in one #if");
		State->active = FALSE;
	    }
	    else {
		State->seen_else = TRUE;
		State->active = State->do_else;
	    }
	    new_token();
	    break;

	  case FEATURE_END:
	    if (State == NULL)
		error(line_count, "#end with no matching #if, ignoring");
	    else
		pop_state();
	    new_token();
	    break;

	  default:
	    if (State == NULL || State->active)
		return yytoken;
	    new_token();
	    break;
	}
    }
}

void add_feature(struct symbol *sym)
{
    if (!feature_present(sym)) {
	struct feature *new = malloc(sizeof(struct feature));
	new->symbol = sym;
	new->next = Features;
	Features = new;
    }
}

void remove_feature(struct symbol *sym)
{
    struct feature *feature, **ptr;

    for (ptr = &Features; (feature = *ptr) != NULL; ptr = &feature->next) {
	if (feature->symbol == sym) {
	    *ptr = feature->next;
	    free(feature);
	    return;
	}
    }
}

void init_feature(void)
{
    char **ptr;

    for (ptr = InitialFeatures; *ptr != NULL; ptr++)
	add_feature(symbol(*ptr));
}

