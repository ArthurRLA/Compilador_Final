
%{
#include "minimo.tab.h"

int lin=1, col=1;
%}

DIGITO 	[0-9]
LETRA	[A-Za-z_]

%%
" "		    { col+=yyleng;}
\n		    { lin++; col=1; }
"+"	    	{ col+=yyleng; return MAIS; }
"*"		    { col+=yyleng; return MULT; }
"-"		    { col+=yyleng; return MENOS; }
"("		    { col+=yyleng; return ABRE_PARENTESES; }
")"		    { col+=yyleng; return FECHA_PARENTESES; }
"{"		    { col+=yyleng; return ABRE_CHAVES; }
"}"		    { col+=yyleng; return FECHA_CHAVES; }
";"		    { col+=yyleng; return PONTO_E_VIRGULA; }
"int"	    { col+=yyleng; return INT; }
"main"	    { col+=yyleng; return MAIN; }
"return"	{ col+=yyleng; return RETURN; }
"="         { col+=yyleng; return IGUAL; }
"=="        { col+=yyleng; return COMPARACAO;}
"<"         { col+=yyleng; return MENOR_QUE;}
">"         { col+=yyleng; return MAIOR_QUE;}
">="        { col+=yyleng; return MAIOR_IGUAL;}
"<="        { col+=yyleng; return MENOR_IGUAL;}
"!="        { col+=yyleng; return DIFERENTE;}

{DIGITO}+	{ col+=yyleng; yylval.integer=atoi(yytext); return NUM; }
{LETRA}({LETRA}|{DIGITO})* { col+=yyleng; yylval.caracter=strdup(yytext); return ID; }
.			{ col+=yyleng;}
%%

