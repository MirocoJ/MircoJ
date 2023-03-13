(* Semantically-checked Abstract Syntax Tree and functions for printing it *)

open Ast

type sexpr = typ * sx
and sx = 
  SLiteral of int
| SDliteral of string
| SBoolLit of bool
| SStringLiteral of string
| SId of string
| SBinop of sexpr * op * sexpr
| SUnop of uop * sexpr
| SObjListDef of string * string list * string
| SAccess of sexpr * sexpr
| SObjMethod of string * string * sexpr list
| SObjDef of typ * string
| SDefAsn of typ * string *  sexpr option
(* | SPreDefAsn of typ * string * expr option *)
(* | SObjDefAsn of typ * string * expr *)
| SAsn of string * sexpr
(* | SObjAsn of string * expr *)
| SCall of string * sexpr list
| SControlFlow of controlFlow
| SListExpr of sexpr list option
| SIndexing of string * sexpr list * sexpr option
| SParenExp of sexpr
(* | SSetDim of expr list *)
| SNewExpr of sexpr
| SNull
| SThis
| SSuper
| SNoexpr

type sstmt =
    SBlock of sstmt list
  | SExpr of sexpr
  | SReturn of sexpr
  | SIf of sexpr * sstmt * sstmt
  | SFor of sexpr * sexpr * sexpr * sstmt
  | SWhile of sexpr * sstmt

type sfundef = 
{
  ty : typ;
  id : string;
  args : (typ * string) list;
  body : sstmt list;
}

type sclassStmt =  
    ConstructorDef of typ * (typ * string) list * sstmt list
  | FieldDef of accControl option * fieldModifier option* typ * string * sexpr option
  | MethodDef of accControl option * fieldModifier option * sfundef

type sclassdef = 
  {
   id : string;
   father: string option;
   interface: string list option;
   body: sclassStmt list;
   }

type sabsFunDef = 
{
  fieldM : fieldModifier option;
  ty : typ;
  id : string;
  args : (typ * string) list;
}

type sinterfaceDef =  
    { 
      id : string; 
      extend_members : string list option;
      body : sabsFunDef list;
    }

type sprogramComp = 
    SStmt of sstmt
  | SFun of sfundef
  | SClass of sclassdef
  | SInterface of sinterfaceDef 

type sprogram = sprogramComp list


(* Unparser function *)
let string_of_op = function
    Add -> "+"
  | Sub -> "-"
  | Mult -> "*"
  | Div -> "/"
  | Equal -> "=="
  | Neq -> "!="
  | Less -> "<"
  | Leq -> "<="
  | Greater -> ">"
  | Geq -> ">="
  | And -> "&&"
  | Or -> "||"

let string_of_program = print_string "this is a dummy"