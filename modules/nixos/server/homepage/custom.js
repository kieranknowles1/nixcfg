'use strict'

const LOCAL_DOMAIN = 'tycho.local'
const PUBLIC_DOMAIN = 'selwonk.uk'

// Rewrite *.domain.com links to *.hostname.local IF we're using hostname.local,
// and drop SSL due to the lack of a certificate
if (window.location.href.includes(LOCAL_DOMAIN)) {
  document.querySelectorAll('a').forEach(link => {
    link.href = link.href
      .replace(PUBLIC_DOMAIN, LOCAL_DOMAIN)
      .replace('https://', 'http://')
  })
}
