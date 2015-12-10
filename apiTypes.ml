type 'a api_response =
  | OK of 'a
  | Error of string
  | AuthenticationFailure
  | NotFound
  | UnsuccessfulExecution

type grade =
  A of int | B of int | C of int | D of int | E of int | F of int | G of int

type transfer_frequency = 
  | LoadNow
  | LoadOnce
  | LoadWeekly
  | LoadBiweekly
  | LoadDayOneSixteen
  | LoadMonthly

type loan_purpose =
  | DebtConsolidation
  | Medical
  | HomeImprovement
  | RenewableEnergy
  | SmallBusiness
  | Wedding
  | Vacation
  | Moving
  | House
  | Car
  | MajorPurchase
  | CreditCard
  | Other

type home_ownership = 
  | Own
  | Rent
  | Mortgage
  | Other
 
type credit_trend = Up | Down | Flat

type fico_range = int * int

type transfer_operation = AddFunds | WithdrawFunds

type percent = float 

type account = {
  mutable available_cash : float;
  mutable investor_id : int;
  mutable accrued_interest : float;
  mutable outstanding_principal : float;
  mutable account_total : float;
  mutable total_notes : int;
  mutable total_portfolios : int;
  mutable in_funding_balance : float;
  mutable received_interest : float;
  mutable received_principal : float;
  mutable received_late_fees : float;
}

type portfolio = {
  mutable id : int;
  mutable name : string;
  mutable description : string option;
}

type application_type = Individual | Joint

type note = {
  mutable status : string;
  mutable id : int;
  mutable loan_id : int;
  mutable portfolio_id : int option;
  mutable portfolio_name : string option;
  mutable grade : grade;
  mutable loan_amount : float;
  mutable note_amount : float;
  mutable accrued_interest : float;
  mutable purpose : string;
  mutable interest_rate : percent;
  mutable order_id : int;
  mutable loan_length : int;
  mutable issue_date : string option;
  mutable order_date : string;
  mutable status_date : string;
  mutable credit_trend : credit_trend;
  mutable current_payment_status : string option;
  mutable can_be_traded : bool;
  mutable payments_received : float;
  mutable next_payment_date : string option;
  mutable principal_pending : float;
  mutable interest_pending : float;
  mutable principal_received : float;
  mutable application_type : application_type option;
}

type loan = {
  mutable id : int;
  mutable loan_amount : float;
  mutable funded_amount : float;
  mutable term : int;
  mutable interest_rate : percent;
  mutable expected_default_rate : percent;
  mutable service_fee_rate : percent;
  mutable installment : float;
  mutable grade : grade;
  mutable employment_length : int option;
  mutable home_ownership : home_ownership option;
  mutable annual_income : float option;
  mutable income_verified : bool option;
  mutable approved : bool;
  mutable purpose : loan_purpose;
  mutable investor_count : int option;
  mutable fico_range : fico_range;
  mutable inq_last_6_mths : int;
  mutable mths_since_last_delinq : int;
  mutable mths_since_last_major_derog : int;
  mutable debt_to_income : float option;
  mutable credit_utilization : float option;
}

type order = {
  loan_id : int;
  amount : float;
  portfolio_id : int option;
}

type fund_transfer = {
  id : int;
  date : string;
  amount : float;
  source_account : string;
  status : string;
  frequency : transfer_frequency;
  end_date : string option;
  operation : string;
  cancellable : bool;
}

let default_account () = {
  available_cash = 0.0;
  investor_id = 0;
  accrued_interest = 0.0;
  outstanding_principal = 0.0;
  account_total = 0.0;
  total_notes = 0;
  total_portfolios = 0;
  in_funding_balance = 0.0;
  received_interest = 0.0;
  received_late_fees = 0.0;
  received_principal = 0.0;
}

let default_note () = {
  status = "";
  id = 0;
  loan_id = 0;
  portfolio_id = None;
  portfolio_name = None;
  grade = A 1;
  loan_amount = 0.0;
  note_amount = 0.0;
  accrued_interest = 0.0;
  purpose = "";
  interest_rate = 0.0;
  order_id = 0;
  loan_length = 0;
  issue_date = None;
  order_date = "";
  status_date = "";
  credit_trend = Down;
  current_payment_status = None;
  can_be_traded = false;
  payments_received = 0.0;
  next_payment_date = None;
  principal_pending = 0.0;
  interest_pending = 0.0;
  principal_received = 0.0;
  application_type = None;
}

let default_loan () = {
  id = 0;
  loan_amount = 0.0;
  funded_amount = 0.0;
  term = 0;
  interest_rate = 0.0;
  expected_default_rate = 0.0;
  service_fee_rate = 0.0;
  installment = 0.0;
  grade = A 1;
  employment_length = None;
  home_ownership = None;
  annual_income = None;
  income_verified = None;
  approved = false;
  purpose = Other;
  investor_count = None;
  fico_range = (0, 0);
  inq_last_6_mths = 0;
  mths_since_last_delinq = 0;
  mths_since_last_major_derog = 0;
  debt_to_income = None;
  credit_utilization = None;
}
