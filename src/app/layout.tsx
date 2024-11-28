import type { Metadata } from "next";
import { DM_Serif_Display, JetBrains_Mono } from "next/font/google";
import "./globals.css";

const notoSerif = DM_Serif_Display({
  weight: "400",
  preload: false,
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
        className={`${notoSerif.className} ${jetbrainsMono.variable} antialiased`}
      >
        {children}
      </body>
    </html>
  );
}
