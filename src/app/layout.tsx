import type { Metadata } from "next";
import { Montserrat, DM_Serif_Display, JetBrains_Mono } from "next/font/google";
import "./globals.css";

const notoSerif = DM_Serif_Display({
  weight: "400",
  preload: false,
  variable: "--font-dm-serif-display",
});

const montserrat = Montserrat({
  weight: "500",
  preload: false,
  variable: "--font-noto-sans",
});

const jetbrainsMono = JetBrains_Mono({
  subsets: ["latin"],
  preload: false,
  variable: "--font-jetbrains-mono",
});

export const metadata: Metadata = {
  title: "React-tRace",
  description: "A React hooks interpreter based on a formal semantics",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body
        className={`${notoSerif.variable} ${montserrat.variable} ${jetbrainsMono.variable} antialiased px-6 py-6 max-w-xl mx-auto md:max-w-2xl`}
      >
        {children}
      </body>
    </html>
  );
}
