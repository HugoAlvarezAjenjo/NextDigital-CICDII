import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: {
      "/api/v2": {
        target: "http://localhost:5180",
        changeOrigin: true,
      },
      "/auth": {
        target: "http://localhost:5190",
        changeOrigin: true,
      },
    },
  },
});
