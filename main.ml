open ApiTypes
open Printf
open Unix

let config_path = (getpwuid (getuid ())).pw_dir ^ "/.config/lendc/lendc.conf"

let print_result printfun = function
  | OK r -> printfun r
  | _ -> print_endline "API returned error!"

let read_ctx_from_config () =
  let api_key = ref "" and aid = ref 0 in
  begin
  match Yojson.Basic.from_file config_path with
  | `Assoc l -> List.iter (function
    | "api-key", `String key -> api_key := key;
    | "account-id", `Int id -> aid := id;
    | _ -> ignore ()) l
  | _ -> failwith "Malformed config file"
  end; (!api_key, !aid)

let () =
  if Array.length Sys.argv < 2 then begin
    printf "Usage: %s [account | notes | loans]\n" Sys.argv.(0);
  end else
  try let ctx = read_ctx_from_config () in
    match Sys.argv.(1) with
    | "account" -> Request.get_account ctx |> print_result Print.print_account
    | "loans" -> Request.get_loans ctx |> print_result
      (fun (date, loans) -> print_endline ("Loans as of " ^ date);
                            Print.print_loans loans)
    | "notes" -> Request.get_notes ctx |> print_result Print.print_notes
    | "portfolios" -> Request.get_portfolios ctx |> print_result Print.print_portfolios
    | _ -> print_endline "Error: unrecognized command"
  with _ ->
    print_endline "Error: nonexistent or malformed config file:";
    print_endline config_path
