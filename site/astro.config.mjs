import { defineConfig } from "astro/config";

// https://astro.build/config
export default defineConfig({
  site: "https://sohansubhash.github.io",
  base: "/substrate", // Only needed if not using yourusername.github.io repo
  output: "static",
});
