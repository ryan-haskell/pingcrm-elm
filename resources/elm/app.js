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
let elmApp = Main.init({
  node,
  flags: {
    window: { width: window.innerWidth },
    pageData,
    xsrfToken 
  }
})

// PORTS
let ports = toPorts(elmApp)

ports.refreshXsrfToken.subscribe(() => {
  let xsrfToken = refreshXsrfToken()
  ports.onXsrfTokenRefreshed.send(xsrfToken)
})
ports.reportJsonDecodeError.subscribe(reportJsonDecodeError)
ports.reportNavigationError.subscribe(reportNavigationError)

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

function reportNavigationError ({ url, error }) {
  ports.onNavigationError.send({ url, error })

  if (import.meta.env.DEV) {
    console.warn(url + '\n\n' + error)
  } else {
    // In production, report these errors to Sentry, etc
  }
}


/**
 * In Elm, a port that is not called won't be defined in the `app.ports` object.
 * 
 * This uses a Proxy to warn us about missing ports in development, and report
 * them to our Error Reporting service in production.
 * 
 * It also prevents the need to add `if` statements throughout port logic to
 * check for the presence of ports to avoid runtime exceptions.
 */
function toPorts(app) {
  return new Proxy({}, {
    get: (_, key) => new Proxy({}, {
      get: (_, method) => {
        if (typeof app?.ports?.[key]?.[method] === 'function') {
          return app.ports[key][method]
        }
        
        if (import.meta.env.DEV) {
          console.warn('PORTS', `Port "${key}" was not defined`)
        } else {
          // In production, report these errors to Sentry, etc
        }
  
        return () => {}
      }
    })
  })
}