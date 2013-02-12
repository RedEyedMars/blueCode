%{  /* For math functions, cos(), sin(), etc. */
#include <iostream>
#include <stdio.h>
#include <string.h>
#include <vector>
#include "main.h"

 void yyerror (const char *error);
  int  yylex ();

%}

%union {
  double val;
  char* nam;
  expression* expr;
  sequence* seq;
}

%token <val>  NUM        /* Simple double precision number   */
%type <expr> exp function_declaration
%type <seq> function_body 
%token <nam> NAME
%token <expr> FUNC

%right '='
%left '-' '+'
%left '*' '/'
%token DEF
/* Grammar follows */

%%
input:   /* empty */
        | input line
        | input function_declaration
        | input execution
        | input error '\n' { yyerrok;}
;


line:   '\n'
        | ';'
;

many_line: | many_line '\n'
;

execution: exp line {$1-> execute(); cout << $1->ret.d << endl;}

function_declaration: DEF NAME many_line '{' many_line function_body many_line '}' {$$ = $6; $$->name = static_name; func_table.push_back($$); clean_func_names();}
;

function_body: function_body line
	|  function_body line exp  { $$ = $1->add(new sequence($3));}
	|  exp {$$ = new sequence($1);}        
;

exp: exp '+' exp   {expression* pars[] = {$1, $3};  $$ = new expression(plus_func, pars ,2);}
     | NAME '=' exp {$$ = $3; $3 -> name = static_name; func_table.push_back($3); temp_names.push_back($1);}
     | NUM {$$ = new getval($1);}
     | FUNC {$$ = $1;}
     
     
;
/* End of grammar */
%%

#include <stdio.h>
int main ()
{
  yyparse ();
return 0;
}

void yyerror (const char *s)
{
  std::cout << s << std::endl;
}


#include <ctype.h>
int yylex ()
{
  int c;

  /* Ignore whitespace, get first nonwhite character.  */
  while ((c = getchar ()) == ' ' || c == '\t');

  if (c == EOF)
    return 0;

  /* Char starts a number => parse the number.         */
  if (c == '.' || isdigit (c))
    {
      ungetc (c, stdin);
      scanf ("%lf", &yylval.val);
      return NUM;
    }

  /* Char starts an identifier => read the name.       */
  if (isalpha (c))
    {
      static char *symbuf = 0;
      static int length = 0;
      int i;

      /* Initially make the buffer long enough
         for a 40-character symbol name.  */
      if (length == 0)
        length = 40, symbuf = (char *)malloc (length + 1);

      i = 0;
      do
        {
          /* If buffer is full, make it bigger.        */
          if (i == length)
            {
              length *= 2;
              symbuf = (char *)realloc (symbuf, length + 1);
            }
          /* Add this character to the buffer.         */
          symbuf[i++] = c;
          /* Get another character.                    */
          c = getchar ();
        }
      while (c != EOF && isalnum (c));

      ungetc (c, stdin);
      symbuf[i] = '\0';
      if(!strcmp(symbuf,"def"))
	return DEF;
      for(int m=0;m<func_table.size();m++){
	if(func_table[m]->name == symbuf)
	{
	  yylval.expr = func_table[m];
	  return FUNC;
	}
      }
      static_name = symbuf;
      yylval.nam = symbuf;
      return NAME;
    }

  /* Any other character is a token by itself.        */
  return c;
}
