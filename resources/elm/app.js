import '../css/app.css'
import Main from './src/Main.elm'

const node = document.getElementById('app')

// Grab data from Inertia
let pageData = {}
let xsrfToken = ''
try {
  pageData = JSON.parse(node.getAttribute('data-page'))
  console.dir('pageData', pageData)
} catch (err) {
  console.error('Could not get inertia data', err)
}
try {
  xsrfToken = refreshXsrfToken()
} catch (err) {
  console.error('Could not get inertia xsrf token', err)
}

// Start up the Elm application
let app = Main.init({
  node,
  flags: {
    window: { width: window.innerWidth },
    pageData,
    xsrfToken 
  }
})

// Register ports
if (app?.ports?.refreshXsrfToken?.subscribe) {
  app.ports.refreshXsrfToken.subscribe(() => {
    let xsrfToken = refreshXsrfToken()
    if (app.ports.onXsrfTokenRefreshed) {
      app.ports.onXsrfTokenRefreshed.send(xsrfToken)
    }
  })
}

if (app?.ports?.reportJsonDecodeError?.subscribe) {
  app.ports.reportJsonDecodeError.subscribe(reportJsonDecodeError)
}

// Define port handlers
function refreshXsrfToken () {
  return decodeURIComponent(document.cookie.split(';')
    .map(x => x.split('='))
    .map(([key,value]) => key.trim() === 'XSRF-TOKEN' ? value.trim() : undefined)
    .find(x => x !== ''))
}

function reportJsonDecodeError ({ page, error }) {
  if (import.meta.env.DEV) {
    console.warn(page.toUpperCase() + '\n\n' + error)
  } else {
    // In production, report these errors to Sentry, etc
  }
}