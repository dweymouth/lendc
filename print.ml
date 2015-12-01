open ApiTypes

open Printf

let print_notes notes =
  print_endline "Investment  Int. Rate  Grade  Term  Accr. Int.  Paymnt. Recvd.";
  List.iter (fun (note : note) ->
  printf        "$%0.2f      %0.2f%%     %s     %d    $%0.2f       $%0.2f\n"
    note.note_amount note.interest_rate (Convert.string_of_grade note.grade)
    note.loan_length note.accrued_interest note.payments_received) notes

let print_loans loans =
  print_endline "Id    Int. Rate  Grade  Term  Amount  Funded";
  List.iter (fun (loan : loan) ->
  printf        "%d    %02.2f%%    %s     %d    $%0.2f  $%0.2f\n"
    loan.id loan.interest_rate (Convert.string_of_grade loan.grade)
    loan.term loan.loan_amount loan.funded_amount) loans

let print_account (account : account) =
  print_endline ("Account " ^ (string_of_int account.investor_id));
  print_endline("Total: $" ^ (string_of_float account.account_total)
    ^ " ($" ^ (string_of_float account.available_cash) ^ " available)");
  printf "%d total notes in %d portfolios\n" account.total_notes account.total_portfolios;
