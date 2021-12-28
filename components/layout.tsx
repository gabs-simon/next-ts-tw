import { FC } from "react"
import Head from 'next/head'

const layout: FC = ({ children }) => {
  return (
    <div className="min-h-screen w-screen bg-gradient-to-br from-blue-400 to-emerald-400 flex flex-col py-8 px-6">
      <Head>
        <title>[next-ts-tw]: A Next.js template with batteries included.</title>
        <meta name="description" content="next-ts-tw is a template to start your own web apps with Next, TypeScript and Tailwind" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <main className="min-h-11/12 min-w-10/12 grow rounded-xl shadow-xl py-8 px-6 bg-slate-50 dark:bg-slate-900">
        <div className="max-w-full prose prose-sm prose-slate dark:prose-invert font-mono">{children}</div>
      </main>
    </div>
  )
}

export default layout