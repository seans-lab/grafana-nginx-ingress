// Creator: k6 Browser Recorder 0.6.0

import { sleep, group } from 'k6'
import http from 'k6/http'

export const options = { vus: 100, duration: '3m', insecureSkipTLSVerify: true }

export default function main() {
  let response

  group('page_1 - http://nginx-release-nginx-ingress', function () {
    response = http.get('http://nginx-release-nginx-ingress', {
      headers: {
        host: 'coffee-svc',
        accept:
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
        'accept-language': 'en-US,en;q=0.5',
        'accept-encoding': 'gzip, deflate, br',
        connection: 'keep-alive',
        'upgrade-insecure-requests': '1',
        'sec-fetch-dest': 'document',
        'sec-fetch-mode': 'navigate',
        'sec-fetch-site': 'none',
        'sec-fetch-user': '?1',
        'sec-gpc': '1',
      },
    })
    sleep(6.3)
  })

  group('page_2 - http://nginx-release-nginx-ingress', function () {
    response = http.get('http://nginx-release-nginx-ingress', {
      headers: {
        host: 'tea-svc',
        accept:
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
        'accept-language': 'en-US,en;q=0.5',
        'accept-encoding': 'gzip, deflate, br',
        connection: 'keep-alive',
        'upgrade-insecure-requests': '1',
        'sec-fetch-dest': 'document',
        'sec-fetch-mode': 'navigate',
        'sec-fetch-site': 'none',
        'sec-fetch-user': '?1',
        'sec-gpc': '1',
      },
    })
  })
}