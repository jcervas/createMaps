#!/usr/bin/env python3
"""
dra_server.py — Local receiver for DRA block assignment CSVs.

Listens on localhost:9001 for POST requests from the browser automation
script (dra_automation.js). Each request carries a JSON payload with the
map title, ID, and raw CSV text; the server saves it as {title}.csv in
the output directory.

Usage:
    python3 scripts/dra_server.py

Then run dra_automation.js in the browser console on davesredistricting.org.
"""
from http.server import HTTPServer, BaseHTTPRequestHandler
import json, os, sys

OUT_DIR = os.path.expanduser('~/Downloads/dra-block-assignments')
PORT    = 9001

os.makedirs(OUT_DIR, exist_ok=True)


class Handler(BaseHTTPRequestHandler):
    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

    def do_POST(self):
        length = int(self.headers.get('Content-Length', 0))
        body   = self.rfile.read(length)
        try:
            data    = json.loads(body)
            title   = data['title']
            csv_txt = data['csv']

            safe  = title.replace('/', '-').replace('\\', '-').replace(':', '-')
            fpath = os.path.join(OUT_DIR, f'{safe}.csv')

            with open(fpath, 'w') as f:
                f.write(csv_txt)

            rows = csv_txt.count('\n')
            print(f'  SAVED: {safe}.csv ({rows} rows)', flush=True)

            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(json.dumps({'ok': True, 'rows': rows}).encode())

        except Exception as e:
            print(f'ERROR: {e}', flush=True)
            self.send_response(500)
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(str(e).encode())

    def log_message(self, fmt, *args):
        pass  # suppress per-request logs


if __name__ == '__main__':
    print(f'DRA server listening on port {PORT}')
    print(f'Saving CSVs to: {OUT_DIR}')
    sys.stdout.flush()
    HTTPServer(('localhost', PORT), Handler).serve_forever()
