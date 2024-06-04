import '../css/app.css'
import Main from './src/Main.elm'

const node = document.getElementById('app')

let pageData = {}
let xsrfToken = ''
try {
  pageData = JSON.parse(node.getAttribute('data-page'))
  console.dir('pageData', pageData)
} catch (err) {
  console.error('Could not get inertia data', err)
}
try {
  xsrfToken = decodeURIComponent(document.cookie.split(';')
    .map(x => x.split('='))
    .map(([key,value]) => key.trim() === 'XSRF-TOKEN' ? value.trim() : undefined)
    .find(x => x !== ''))
} catch (err) {
  console.error('Could not get inertia xsrf token', err)
}

let app = Main.init({ node, flags: { pageData, xsrfToken } })