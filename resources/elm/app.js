import '../css/app.css'
import Main from './src/Main.elm'

const node = document.getElementById('app')

let pageData = {}
try {
  pageData = JSON.parse(node.getAttribute('data-page'))
  console.dir('InertiaJS', pageData.props)
} catch (err) {
  console.error('Could not get inertia data', err)
}

let app = Main.init({ node, flags: { pageData } })