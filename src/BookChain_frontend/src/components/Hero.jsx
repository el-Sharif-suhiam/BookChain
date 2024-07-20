import React from "react";
export default function Hero() {
  return (
    <section className="relative hero bg-[url(/stack-of-books.jpg)] bg-cover bg-center bg-no-repeat mb-16">
      <div className="absolute inset-0 bg-gray-900/75 from-gray-900/95 to-gray-900/25 ltr:sm:bg-gradient-to-r rtl:sm:bg-gradient-to-l"></div>

      <div className="relative mx-auto max-w-screen-xl px-4 py-32 sm:px-6 lg:flex lg:h-[75vh] lg:items-center lg:px-8">
        <div className="max-w-xl text-center ltr:sm:text-left rtl:sm:text-right">
          <h1 className="text-3xl font-extrabold text-white sm:text-5xl text-left">
            Discover the Future of Reading with
            <strong className="block font-extrabold text-rose-500">
              {" "}
              BookChain!
            </strong>
          </h1>

          <p className="mt-4 max-w-lg text-white sm:text-xl/relaxed">
            Embark on a new adventure with your favorite books on BookChain,
            where books turn into NFTs!
          </p>

          <div className="mt-8 flex flex-wrap gap-4 text-center justify-center">
            <a
              href="/create"
              className="block w-full rounded bg-rose-600 px-12 py-3 text-sm font-medium text-white shadow hover:bg-rose-700 focus:outline-none focus:ring active:bg-rose-500 sm:w-auto"
            >
              Get Started
            </a>

            <a
              href="#"
              className="block w-full rounded bg-white px-12 py-3 text-sm font-medium text-rose-600 shadow hover:text-rose-700 focus:outline-none focus:ring active:text-rose-500 sm:w-auto"
            >
              Learn More
            </a>
          </div>
        </div>
      </div>
    </section>
  );
}
