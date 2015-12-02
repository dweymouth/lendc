open ApiTypes

(* api key, investor id *)
type request_context = (string * int)

let base_url = "https://api.lendingclub.com/api/investor/v1"

let get_headers api_key =
  [ "Accept: application/json"; "Authorization: " ^ api_key ]

let post_headers api_key = 
  "Content-Type: application/json" :: get_headers api_key

let parse_response handle_json (rc, body) =
  match rc with
  | 200 -> OK (Yojson.Basic.from_string body |> handle_json)
  | 400 -> Error (body)
  | 403 -> AuthenticationFailure
  | 404 -> NotFound
  | 500 -> UnsuccessfulExecution
  | _ -> failwith ("Unexpected HTTP response code: " ^ (string_of_int rc))

let get_listed_loans ?(show_all=false) (api_key, _) =
  let (rc, body) = Http.get (base_url ^ "/loans/listing") (get_headers api_key) in
  body

let currency = function
  | `Float f -> f
  | `Int i -> float_of_int i
  | _ -> failwith "Invalid currency JSON type"

let account_subresource investor_id res =
  base_url ^ "/accounts/" ^ (string_of_int investor_id) ^ res

let get_account (api_key, investor_id) =
  Http.get (account_subresource investor_id "/summary") (get_headers api_key)
  |> parse_response (function
    | `Assoc l ->
      let account = default_account () in
      List.iter (function
        | "investorId", `Int id -> account.investor_id <- id;
        | "availableCash", json -> account.available_cash <- (currency json);
        | "accountTotal", json -> account.account_total <- (currency json);
        | "accruedInterest", json -> account.accrued_interest <- (currency json);
        | "infundingBalance", json -> account.in_funding_balance <- (currency json);
        | "receivedInterest", json -> account.received_interest <- (currency json);
        | "receivedPrincipal", json -> account.received_principal <- (currency json);
        | "receivedLateFees", json -> account.received_late_fees <- (currency json);
        | "outstandingPrincipal", json -> account.outstanding_principal <- (currency json);
        | "totalNotes", `Int total -> account.total_notes <- total;
        | "totalPortfolios", `Int total -> account.total_portfolios <- total;
        | (str, _) -> failwith ("Unexpected field " ^ str);
      ) l; account
    | _ -> failwith "Unexpected JSON object")

let get_portfolios (api_key, investor_id) =
  Http.get (account_subresource investor_id "/portfolios") (get_headers api_key)
  |> parse_response (function
     | `Assoc [("myPortfolios", `List portfolios)] ->
       let portfolio = { id = 0; name = ""; description = None } in
       portfolio
     | _ -> failwith "Unexpected JSON object")

let get_notes (api_key, investor_id) =
  Http.get (account_subresource investor_id "/detailednotes") (get_headers api_key)
  |> parse_response (function
     | `Assoc [("myNotes", `List notes)] ->
     List.fold_left (fun notes note_json ->
       match note_json with
       | `Assoc notes_json -> 
         let note = default_note () in
         List.iter (function
           | "loanId", `Int id -> note.loan_id <- id;
           | "noteId", `Int id -> note.id <- id;
           | "orderId", `Int id -> note.order_id <- id;
           | "purpose", `String s -> note.purpose <- s;
           | "interestRate", json -> note.interest_rate <- (currency json);
           | "loanLength", `Int len -> note.loan_length <- len;
           | "loanStatus", `String s -> note.status <- s;
           | "grade", `String s -> note.grade <- Convert.grade_of_string s;
           | "currentPaymentStatus", `String s -> note.current_payment_status <- Some s;
           | "canBeTraded", `Bool b -> note.can_be_traded <- b;
           | "creditTrend", `String s -> note.credit_trend <- Convert.credit_trend_of_string s;
           | "loanAmount", json -> note.loan_amount <- (currency json);
           | "noteAmount", json -> note.note_amount <- (currency json);
           | "accruedInterest", json -> note.accrued_interest <- (currency json);
           | _ -> ignore ()
         ) notes_json; note :: notes
       | _ -> failwith "Unexpected JSON object") [] notes
     | _ -> failwith "Unexpected field in notes response")

let get_loans (api_key, _) : (string * loan list) api_response =
  Http.get (base_url ^ "/loans/listing") (get_headers api_key)
  |> parse_response (function
    | `Assoc base -> (* base object *)
      let as_of_date = ref "" and loans_ref = ref [] in
      List.iter (function
       | "asOfDate", `String s -> as_of_date := s;
       | "loans", `List loans ->
         loans_ref := List.map (function
	   | `Assoc loan_fields ->
	     let loan = default_loan () in
	     List.iter (function
	       | "id", `Int id -> loan.id <- id;
	       | "loanAmount", json -> loan.loan_amount <- (currency json);
	       | "fundedAmount", json -> loan.funded_amount <- (currency json);
	       | "term", `Int term -> loan.term <- term;
	       | "intRate", `Float rate -> loan.interest_rate <- rate;
	       | "expDefaultRate", `Float rate -> loan.expected_default_rate <- rate;
	       | "serviceFeeRate", `Float rate -> loan.service_fee_rate <- rate;
	       | "installment", json -> loan.installment <- (currency json);
	       | "subGrade", `String s -> loan.grade <- Convert.grade_of_string s;
	       | "empLength", `Int i -> loan.employment_length <- Some i;
	       | "homeOwnership", `String s -> (); (* TODO *)
	       | "reviewStatus", `String "APPROVED" -> loan.approved <- true;
	       | _ -> ignore ()
	     ) loan_fields; loan
	   | _ -> failwith "Unexpected JSON object") loans;
       | _ -> failwith "Unexpected field in loans response") base;
       (!as_of_date, !loans_ref)
     | _ -> failwith "Unexpected JSON object")

(* POST operations *)

let create_portfolio (api_key, investor_id) name description =
  Http.post (account_subresource investor_id "/portfolios") (post_headers api_key)
   (Printf.sprintf "{
      \"investorId\":%d,
      \"portfolioName\":\"%s\",
      \"portfolioDescription\":\"%s\"
    }" investor_id name description)

let submit_order (api_key, investor_id) orders =
  let orders_json = List.map (fun order ->
      Printf.sprintf "{
        \"loanId\":%d,
        \"requestedAmount\":%f"
       order.loan_id order.requested_amount ^ 
      match order.portfolio_id with Some i -> Printf.sprintf ",\"portfolioId\":%d}" i
                                  | None -> "}")
    orders |> String.concat "," in 
  Http.post (account_subresource investor_id "/orders") (post_headers api_key)
    (Printf.sprintf "{
      \"aid\":%d,
      \"orders\":[%s]
     }" investor_id orders_json)
