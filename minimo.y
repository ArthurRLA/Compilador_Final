%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define INF -99999

extern int lin;
extern int col;
extern int yyleng;
extern char *yytext;
FILE *f;

typedef struct no{
	int dado;
	char expr[73];
	struct no *prox;
}No;

typedef struct lista{
	No *cabeca;
}Lista;

Lista * criar_lista(){
	Lista *lista;
	lista = (Lista *)malloc(sizeof(Lista));
	if (lista == NULL)
		return NULL;
	printf("LLSE CRIADA\n\n");
	lista->cabeca = NULL;
	return lista;
}

int inserir_lista(Lista *lista, char exp[], int valor){
	No *novo;

	novo = (No *) malloc(sizeof(No));
	if (novo == NULL)
		return 0;

	novo->prox = NULL;
	novo->dado = valor;
	strcpy(novo->expr, exp);

	if (lista->cabeca == NULL)
		lista->cabeca = novo;
	else{
		novo->prox = lista->cabeca;
		lista->cabeca = novo;	
	}
	return 1;
}

int encontrar_expr_lista(Lista*lista, char exp[]){
	No *p;
	if (lista->cabeca == NULL)
		return INF;
	for(p=lista->cabeca; p!=NULL; p=p->prox){
		if(strcmp(p->expr, exp) == 0)
			return p->dado;
	}
	printf("%s NAO DECLARADO\n", exp);
	exit(0);
}

int existe(Lista*lista, char exp[]){
	No *p;
	if (lista->cabeca == NULL)
		return 0;
	for(p=lista->cabeca; p!=NULL; p=p->prox){
		if(strcmp(p->expr, exp) == 0)
			return 1;
	}
	return 0;
}

void substituir(Lista*lista, char exp[], int valor){
	No*p;
	if(p == NULL){
		printf("Sem variaveis declaradas\n");
		return;
	}
	for(p=lista->cabeca; p!=NULL; p=p->prox)
		if(strcmp(exp, p->expr) == 0){
			p->dado = valor;
			break;
		}
}


void mostrar_lista(Lista *lista){ 
	No *p;
	
	if (lista->cabeca == NULL)
		printf("Lista vazia.\n");
	
	for(p=lista->cabeca; p!=NULL; p=p->prox){
		printf("%s: ", p->expr);
		printf("%i\n", p->dado);
	}
}


int yyerror(char *msg){
	printf("%s (%i, %i) token encontrado: \"%s\"\n", msg, lin, col-yyleng, yytext);
	exit(0);
}
int yylex(void);

void montar_codigo_inicial(){
	f = fopen("out.s","w+");
	fprintf(f, ".text\n");
	fprintf(f, "    .global _start\n\n");
	fprintf(f, "_start:\n\n");
}

void montar_codigo_final(){
	fclose(f);

	printf("Arquivo \"out.s\" gerado.\n\n");
}

void montar_codigo_retorno(){
	fprintf(f, "    popq    %%rbx\n");
	fprintf(f, "    movq    $1, %%rax\n");
	fprintf(f, "    int     $0x80\n\n");
}
int montar_codigo_exp(char op){
	switch(op){
		case '+':
			fprintf(f, "    popq    %%rax\n");
			fprintf(f, "    popq    %%rbx\n");
			fprintf(f, "    addq    %%rbx, %%rax\n");
			fprintf(f, "    pushq     %%rax\n\n");
			break;
		case '-':
			fprintf(f, "    popq    %%rbx\n");
			fprintf(f, "    popq    %%rax\n");
			fprintf(f, "    subq    %%rbx, %%rax\n");
			fprintf(f, "    pushq     %%rax\n\n");
			break;
		case '*':
			fprintf(f, "    popq    %%rax\n");
			fprintf(f, "    popq    %%rbx\n");
			fprintf(f, "    imulq    %%rbx, %%rax\n");
			fprintf(f, "    pushq     %%rax\n\n");
			break;
	}
}

void montar_codigo_empilhar(int a){
	fprintf(f, "    pushq    $%i\n",a);
}

Lista *L;

%}

%union {char *caracter; int integer;}
%token INT MAIN ABRE_PARENTESES FECHA_PARENTESES ABRE_CHAVES RETURN PONTO_E_VIRGULA FECHA_CHAVES
%token COMPARACAO MENOR_QUE MAIOR_QUE MAIOR_IGUAL MENOR_IGUAL DIFERENTE
%token MAIS MENOS MULT IGUAL
%token<integer> NUM
%token<caracter> ID 
%left MAIS MENOS
%left MULT
%%

programa	: INT MAIN ABRE_PARENTESES FECHA_PARENTESES ABRE_CHAVES {L = criar_lista(); montar_codigo_inicial();} corpo FECHA_CHAVES {montar_codigo_final();}
			;

corpo		: RETURN exp PONTO_E_VIRGULA {montar_codigo_retorno();} corpo
			| variavel corpo
			|
			;

exp         : exp MAIS exp {montar_codigo_exp('+');}
			| exp MENOS exp {montar_codigo_exp('-');}
			| exp MULT exp {montar_codigo_exp('*');}
			| ABRE_PARENTESES exp FECHA_PARENTESES
			| NUM {montar_codigo_empilhar($1);}
			| ID {if(existe(L, $1)==1){
					int d = encontrar_expr_lista(L, $1);
					montar_codigo_empilhar(d);
					}else exit(0);
				}
			| exp simbolos exp
			;

simbolos	:
			| COMPARACAO 
			| MENOR_QUE 
			| MAIOR_QUE 
			| MAIOR_IGUAL 
			| MENOR_IGUAL 
			| DIFERENTE
			;


variavel	: INT ID PONTO_E_VIRGULA {inserir_lista(L, $2, 0);} 
			| INT ID IGUAL NUM PONTO_E_VIRGULA{inserir_lista(L, $2, $4);}
			| INT ID IGUAL ID PONTO_E_VIRGULA{int temp = encontrar_expr_lista(L, $4); inserir_lista(L, $2, temp);}
			| ID IGUAL NUM PONTO_E_VIRGULA{ existe(L, $1)==1?substituir(L, $1, $3):exit(0);}
			| ID IGUAL ID PONTO_E_VIRGULA{if((existe(L, $1)==1 ) && (existe(L, $3)==1)){
								int temp = encontrar_expr_lista(L, $3);
								substituir(L, $1, temp);
							}else exit(0);}
			;
%%
int main(){
	yyparse();
	printf("\nListaE com variaveis\n");
	mostrar_lista(L);
	printf("Está funfando\n");
}
