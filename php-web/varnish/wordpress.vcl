backend default {
    .host = "127.0.0.1";
    .port = "8080";
}
acl purge {
        "localhost";
}

sub vcl_recv {
        if (req.request == "PURGE") {
                if (!client.ip ~ purge) {
                        error 405 "Not allowed.";
                }
                return(lookup);
        }
        if (req.url ~ "^/$") {
               unset req.http.cookie;
        }
}
sub vcl_hit {
        if (req.request == "PURGE") {
                set obj.ttl = 0s;
                error 200 "Purged.";
        }
}
sub vcl_miss {
        if (req.request == "PURGE") {
                error 404 "Not in cache.";
        }
        if (!(req.url ~ "wp-(login|admin)")) {
                unset req.http.cookie;
        }
        if (req.url ~ "^/[^?]+.(jpeg|jpg|png|gif|ico|js|css|txt|gz|zip|lzma|bz2|tgz|tbz|html|htm)(\?.|)$") {
                unset req.http.cookie;
                set req.url = regsub(req.url, "\?.$", "");
        }
        if (req.url ~ "^/$") {
                unset req.http.cookie;
        }
}
sub vcl_fetch {
        if (req.url ~ "^/$") {
                unset beresp.http.set-cookie;
        }
        if (!(req.url ~ "wp-(login|admin)")) {
                unset beresp.http.set-cookie;
        }
}
