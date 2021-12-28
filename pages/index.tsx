import Head from 'next/head'

export default function Home() {
  return (
    <div className="min-h-screen w-screen">
      <Head>
        <title>next-ts-tw</title>
        <meta name="description" content="NextJS, Typescript and Tailwind" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <main>
        <h1>
          Hello World!
        </h1>
      </main>

    </div>
  )
}
