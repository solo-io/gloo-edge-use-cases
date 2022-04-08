package test

default deny = false

deny {
    not input.check_request.attributes.request.http.headers["x-required"]
}
