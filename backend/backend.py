#!/usr/bin/env python3

import json, sys, hashlib
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

NAME = sys.argv[1]
PORT = int(sys.argv[2])

CACHED_BODY = json.dumps({"message": "cacheable content", "version": 1}).encode()
CACHED_ETAG = '"' + hashlib.md5(CACHED_BODY).hexdigest() + '"'
CACHE_CC = "public, max-age=60"

class Handler(BaseHTTPRequestHandler):
    def reply(self, code, body, extra=None):
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("X-Backend", NAME)
        for k, v in (extra or {}).items():
            self.send_header(k, v)
        self.end_headers()
        if self.command != "HEAD":
            self.wfile.write(body)

    def do_GET(self):
        if self.path == "/":
            body = json.dumps({"service": "running", "backend": NAME}).encode()
            self.reply(200, body, {"Cache-Control": "no-store"})
        elif self.path == "/api/status":
            body = json.dumps({"backend": NAME, "status": "ok"}).encode()
            self.reply(200, body, {"Cache-Control": "no-store"})
        elif self.path == "/api/cached":
            if self.headers.get("If-None-Match") == CACHED_ETAG:
                self.send_response(304)
                self.send_header("ETag", CACHED_ETAG)
                self.send_header("Cache-Control", CACHE_CC)
                self.send_header("X-Backend", NAME)
                self.end_headers()
            else:
                self.reply(200, CACHED_BODY, {"Cache-Control": CACHE_CC, "ETag": CACHED_ETAG})
        else:
            self.reply(404, json.dumps({"error": "not found"}).encode())

    do_HEAD = do_GET

if __name__ == "__main__":
    ThreadingHTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
