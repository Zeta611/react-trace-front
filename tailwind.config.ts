import type { Config } from "tailwindcss";

export default {
  content: ["./src/**/*.{js,ts,jsx,tsx,mdx}"],
  theme: {
    extend: {
      colors: {
        background: "var(--background)",
        foreground: "var(--foreground)",
      },
    },
    fontFamily: {
      serif: ["var(--font-dm-serif-display)", "serif"],
      sans: ["var(--font-noto-sans)", "sans-serif"],
      mono: ["var(--font-jetbrains-mono)", "monospace"],
    },
  },
  plugins: [],
} satisfies Config;
