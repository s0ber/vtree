import { resolve } from 'path'
import { defineConfig } from 'vite'
import dts from 'vite-plugin-dts'
import browserslistToEsbuild from 'browserslist-to-esbuild'

export default defineConfig({
  build: {
    target: browserslistToEsbuild(),
    sourcemap: true,
    lib: {
      // Could also be a dictionary or array of multiple entry points
      entry: resolve(__dirname, 'src/index.ts'),
      name: 'Vtree',
      // the proper extensions will be added
      fileName: 'vtree',
    },
    rollupOptions: {
      external: ['jquery']
    }
  },
  plugins: [
    dts({
      rollupTypes: true, // will merge all declarations together
      include: ["src/**/*"]
    })
  ]
})
