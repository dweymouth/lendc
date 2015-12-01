#include <stdlib.h>
#include <string.h>

#include <curl/curl.h>

#include <caml/alloc.h>
#include <caml/compatibility.h>
#include <caml/memory.h>
#include <caml/mlvalues.h>

#define CAML_LIST_FOREACH(item, list) \
  CAMLparam1(list);\
  CAMLlocal1(item);\
  while (list != Val_emptylist) {\
    item = Field(list, 0);\
    list = Field(list, 1);

#define CAML_CREATE_TUPLE(tup, item1, item2)\
  CAMLlocal1(tup);\
  tup = caml_alloc_tuple(2);\
  Store_field(tup, 0, item1);\
  Store_field(tup, 1, item2);

struct buffer {
	char *buf;
	size_t size;
};

static void buffer_init(struct buffer *buf)
{
	buf->buf = malloc(1);
	buf->size = 0;
}

static size_t write_callback(void *data, size_t size, size_t nmemb, void *userp)
{
	size_t realsize = size * nmemb;
	struct buffer *buf = (struct buffer *)userp;
	buf->buf = realloc(buf->buf, buf->size + realsize + 1);
	memcpy(&(buf->buf[buf->size]), data, realsize);
	buf->size += realsize;
	buf->buf[buf->size] = '\0';
	return realsize;
}

static CURLcode perform_curl(CURL *c, int *httpCode)
{
	CURLcode res = curl_easy_perform(c);
	curl_easy_getinfo(c, CURLINFO_RESPONSE_CODE, httpCode);
	curl_easy_cleanup(c);
}

CAMLprim value
caml_get(value sUrl, value slHeaders)
{
	struct buffer buf;
	buffer_init(&buf);
	CURL *c = curl_easy_init();

	curl_easy_setopt(c, CURLOPT_URL, String_val(sUrl));
	curl_easy_setopt(c, CURLOPT_WRITEFUNCTION, write_callback);
	curl_easy_setopt(c, CURLOPT_WRITEDATA, (void*)&buf);

	struct curl_slist *hdr_list = NULL;
	CAML_LIST_FOREACH(header, slHeaders)
		hdr_list = curl_slist_append(hdr_list, String_val(header));
	}
	curl_easy_setopt(c, CURLOPT_HTTPHEADER, hdr_list);

	int httpCode;
	CURLcode curlCode = perform_curl(c, &httpCode);
	if (curlCode != 0) {
		free(buf.buf);
		caml_raise_with_arg("caml_http_exception", Val_int(curlCode));
	} else {
		CAML_CREATE_TUPLE(ret, Val_int(httpCode), caml_copy_string(buf.buf));
		free(buf.buf);
		CAMLreturn(ret);
	}
}

CAMLprim value
caml_post(value sUrl, value slHeaders, value sBody)
{
	struct buffer buf;
	buffer_init(&buf);
	CURL *c = curl_easy_init();

	curl_easy_setopt(c, CURLOPT_URL, String_val(sUrl));
	curl_easy_setopt(c, CURLOPT_WRITEFUNCTION, write_callback);
	curl_easy_setopt(c, CURLOPT_WRITEDATA, (void*)&buf);

	struct curl_slist *hdr_list = NULL;
	CAML_LIST_FOREACH(header, slHeaders)
		hdr_list = curl_slist_append(hdr_list, String_val(header));
	}
	curl_easy_setopt(c, CURLOPT_HTTPHEADER, hdr_list);

	curl_easy_setopt(c, CURLOPT_POST, 1);
	curl_easy_setopt(c, CURLOPT_POSTFIELDS, String_val(sBody));
	curl_easy_setopt(c, CURLOPT_POSTFIELDSIZE, caml_string_length(sBody));

	int httpCode;
	perform_curl(c, &httpCode);

	CAML_CREATE_TUPLE(ret, Val_int(httpCode), caml_copy_string(buf.buf));
	free(buf.buf);
	CAMLreturn(ret);
}
