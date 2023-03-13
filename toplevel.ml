open Ast

let () =
  let lex_buf = Lexing.from_channel stdin in
  let ast = Parser.program Scanner.token lex_buf in
  let sast = Semant.check ast in
  let res = Sast.string_of_program sast in
  print_endline res;;

