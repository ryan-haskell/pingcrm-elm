import { defineConfig } from 'vite'
import laravel from 'laravel-vite-plugin'
import elm from 'vite-plugin-elm-watch'

const isInDevelopment = process.env.NODE_ENV === 'development'

export default defineConfig({
  plugins: [
    laravel({
      input: 'resources/elm/app.js',
      refresh: true,
    }),
    elm({ mode: isInDevelopment ? 'debug' : 'minify' })
  ],
})
