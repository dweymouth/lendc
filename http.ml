exception HttpException of int
let _ = Callback.register_exception "caml_http_exception" (HttpException 0)

type url = string
type headers = string list
type response_code = int

external get : url -> headers -> response_code * string = "caml_get"

external post : url -> headers -> string -> response_code * string = "caml_post"
