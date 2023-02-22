%{
open Ast
%}

%token SEMI LPAREN RPAREN LBRACE RBRACE LSQUARE RSQUARE COMMA PLUS MINUS TIMES DIVIDE ASSIGN DOT CONSTRUCTOR 

%token NOT EQ NEQ LT LEQ GT GEQ AND OR
%token RETURN IF ELSE FOR WHILE INT BOOL DOUBLE VOID STRING BREAK CONTINUE INTLIST BOOLLIST DOUBLELIST STRINGLIST
%token CLASS INTERFACE NEW IMPLEMENTS EXTENDS IS PUBLIC PRIVATE PROTECT STATIC THIS NULL
%token <int> LITERAL
%token <bool> BLIT
%token <string> ID DLIT STRINGLIT
%token EOF

%start program
%type <Ast.program> program

%nonassoc NOELSE 
%nonassoc ELSE DEF
%right ASSIGN 
%left OR
%left AND
%left EQ NEQ
%left LT GT LEQ GEQ
%left PLUS MINUS
%left TIMES DIVIDE
%right NOT
%left DOT
%nonassoc CLASSNAME
%nonassoc CLASSNAMEL
%nonassoc CLASSNAMELL

%%

program:
    programComp_list EOF { List.rev $1 }

programComp_list:
    /* nothing */    { [] }
    | programComp_list programComp { $2 :: $1 }

programComp:
    stmt {Stmt $1}
    // stmt_list    {Stmt (List.rev $1)}
  | fundef       {Fun  ($1)}
  | classdef     {Class($1)}
  | interfacedef {Interface($1)}

fundef:
    typ ID LPAREN formals_opt RPAREN LBRACE stmt_list RBRACE
        {{  ty = $1;
            id = $2;
            args = List.rev $4;
            body = List.rev $7}}

formals_opt:
    /* nothing */ { [] }
  | formal_list   { $1 }

formal_list:
    typ ID                   { [($1,$2)]     }
  | formal_list COMMA typ ID { ($3,$4) :: $1 }

classdef:
    CLASS ID father_opt interface_opt LBRACE class_stmt_list RBRACE
        {{ id = $2;
           father =  $3; 
           interface = $4;
           body = List.rev $6;}}

father_opt:
      EXTENDS ID  {Some $2}
    | {None}
    

interface_opt:
      IMPLEMENTS id_list {Some (List.rev $2)}
    | {None}

id_list:
      ID      {[$1]}
    | id_list COMMA ID  {$3 :: $1}    

interfacedef:
    INTERFACE ID extend_mem_opt LBRACE absFundef_list RBRACE
        {{ 
           id = $2;
           extend_members = $3;
           body = List.rev $5;
        }}

extend_mem_opt:
    | EXTENDS id_list {Some (List.rev $2)}
    | {None}

absFundef_list:
      /* nothing */ {[]}
    | absFundef_list absFundef {$2 :: $1}

absFundef:
    fieldMod typ ID LPAREN formals_opt RPAREN SEMI
        {{  
            fieldM = $1;
            ty = $2;
            id = $3;
            args = List.rev $5;
        }}

class_stmt_list:
    /* nothing */         {[]}
    | class_stmt_list class_stmt {$2 :: $1}

class_stmt:
      CONSTRUCTOR typ LPAREN formals_opt RPAREN LBRACE construct_stmt_list RBRACE
       {ConstructorDef ($2, List.rev $4, List.rev $7)}
    | accControl fieldMod fundef {MethodDef ($1, $2, $3)}
    | accControl fieldMod typ ID def_stmt SEMI {FieldDef ($1, $2, $3, $4, $5)}



construct_stmt_list:
    /* nothing */ {[]}
    | construct_stmt_list construct_stmt {$2 :: $1}

construct_stmt:
    THIS DOT ID ASSIGN expr SEMI {($3, $5)}

accControl:
      PUBLIC  {Some Public}
    | PRIVATE {Some Private}
    | PROTECT {Some Protect}
    | {None}
    
fieldMod:
      STATIC  {Some Static}
    | {None}
square_list:
      LSQUARE RSQUARE   {["[]"]}
    | square_list LSQUARE RSQUARE {"[]" :: $1}
    
list_type:
    INT square_list %prec NOT{IntList $2}
  | BOOL square_list %prec NOT{BoolList $2}
  | DOUBLE square_list %prec NOT{DoubleList $2}
  | STRING square_list %prec NOT{StringList $2}
  | ID square_list %prec CLASSNAME{ObjectList ($1, $2)}

typ: 
    INT  {Int}
  | BOOL {Bool}
  | DOUBLE {Double}
  | VOID {Void}
  | STRING {String}
  | ID %prec CLASSNAME{Object $1}
  | list_type {$1}

  
stmt_list:
    /* nothing */  { [] }
  | stmt_list stmt { $2 :: $1 }

stmt:
    expr SEMI                               { Expr $1}
  | RETURN expr_opt SEMI                    { Return $2}
  | IF LPAREN expr RPAREN stmt %prec NOELSE { If($3, $5, Block([])) }
  | LBRACE stmt_list RBRACE                 { Block(List.rev $2)    }
  | IF LPAREN expr RPAREN stmt ELSE stmt    { If($3, $5, $7)        }
  | FOR LPAREN expr_opt SEMI expr SEMI expr_opt RPAREN stmt
                                            { For($3, $5, $7, $9)   }
  | WHILE LPAREN expr RPAREN stmt           { While($3, $5)         }

controlFlow:
    BREAK    {Break}
  | CONTINUE {Continue}

expr_opt:
    /* nothing */ { Noexpr }
  | expr          { $1 }

expr:
     THIS             {This}
  |  LITERAL          { Literal($1)            }
  | DLIT	         { Dliteral($1)           }
  | BLIT             { BoolLit($1)            }
  | STRINGLIT        { StringLiteral($1)      }
  | NULL             { Null }
  | ID     %prec NOELSE          { Id($1)                 }
  | expr PLUS   expr { Binop($1, Add,   $3)   }
  | expr MINUS  expr { Binop($1, Sub,   $3)   }
  | expr TIMES  expr { Binop($1, Mult,  $3)   }
  | expr DIVIDE expr { Binop($1, Div,   $3)   }
  | expr EQ     expr { Binop($1, Equal, $3)   }
  | expr NEQ    expr { Binop($1, Neq,   $3)   }
  | expr LT     expr { Binop($1, Less,  $3)   }
  | expr LEQ    expr { Binop($1, Leq,   $3)   }
  | expr GT     expr { Binop($1, Greater, $3) }
  | expr GEQ    expr { Binop($1, Geq,   $3)   }
  | expr AND    expr { Binop($1, And,   $3)   }
  | expr OR     expr { Binop($1, Or,    $3)   }
  | MINUS expr %prec NOT { Unop(Neg, $2)      }
  | NOT expr         { Unop(Not, $2)          }
  // | ID ID           %prec ELSE {ObjDef($1, $2)}
  // | ID square_list ID  {ObjListDef ($1, $2, $3)}
  | expr DOT expr    {Access ($1, $3)       }
  | ID ASSIGN expr   { Asn($1, $3)            }
  | ID ASSIGN NEW expr %prec NOT { ObjAsn($1, $4)}
  | ID LPAREN args_opt RPAREN { Call($1, $3)  }
  | typ ID ASSIGN NEW expr %prec OR { ObjDefAsn($1, $2, $5) }
  // | ID DOT ID LPAREN args_opt RPAREN %prec NOT{ObjMethod ($1, $3, $5)}
//   | typ ID           %prec DEF          {PreDef($1, $2)}
  | typ ID def_stmt  %prec ASSIGN { PreDefAsn($1, $2, $3)}
  | LPAREN expr RPAREN { $2                   }
  | controlFlow       {ControlFlow($1)}
  | LSQUARE expr_list_opt RSQUARE {ListExpr ($2)}
  | ID LSQUARE expr RSQUARE def_stmt{Indexing($1, $3, $5)}
  
expr_list_opt:
    expr_list {Some $1}
    | {None}
    
expr_list:
      expr  {[$1]}
    | expr_list COMMA expr {$1 @ [$3]}

def_stmt:
    | ASSIGN expr {Some $2}
    | {None}
  

args_opt:
    /* nothing */ { [] }
  | args_list  { List.rev $1 }

args_list:
    expr                    { [$1] }
  | args_list COMMA expr { $3 :: $1 }

