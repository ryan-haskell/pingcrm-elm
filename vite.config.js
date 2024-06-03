import { defineConfig } from 'vite'
import laravel from 'laravel-vite-plugin'
import vue from '@vitejs/plugin-vue'
import elm from 'vite-plugin-elm-watch'

export default defineConfig({
    plugins: [
        laravel({
            input: 'resources/elm/app.js',
            refresh: true,
        }),
        vue({
            template: {
                transformAssetUrls: {
                    base: null,
                    includeAbsolute: false,
                },
            },
        }),
        elm({ mode: 'standard' })
    ],
})
