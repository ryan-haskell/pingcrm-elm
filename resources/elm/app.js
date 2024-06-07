import '../css/app.css'
import Main from './src/Main.elm'
import { createInertiaApp } from './src/elm-inertia'

let app = createInertiaApp({
  init: Main.init,
  node: document.getElementById('app'),
  flags: {
    window: {
      width: window.innerWidth,
      height: window.innerHeight
    }
  },
  onPortNotFound: (name) => {
    if (import.meta.env.DEV) {
      console.warn('PORTS', `Port "${name}" was not defined`)
    } else {
      // In production, report these errors to Sentry, etc
    }
  }
})

// Handle custom Elm ports
app.ports.onReportJsonDecodeError.subscribe(reportJsonDecodeError)
app.ports.onReportNavigationError.subscribe(reportNavigationError)

function reportJsonDecodeError ({ component, error }) {
  if (import.meta.env.DEV) {
    console.warn(component.toUpperCase() + '\n\n' + error)
  } else {
    // In production, report these errors to Sentry, etc
  }
}

function reportNavigationError ({ url, error }) {
  app.ports.onNavigationError.send({ url, error })

  if (import.meta.env.DEV) {
    console.warn(url + '\n\n' + error)
  } else {
    // In production, report these errors to Sentry, etc
  }
}