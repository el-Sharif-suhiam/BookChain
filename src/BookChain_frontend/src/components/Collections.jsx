import React from "react";
import { BookChain_backend } from "declarations/BookChain_backend";

export default function Collections() {
  //md:grid-cols-3 lg:grid-cols-4 sm:grid-cols-2  grid-cols-1
  const [books, setBooks] = React.useState([]);

  React.useEffect(() => {
    const fetchData = async () => {
      const data = await BookChain_backend.getBookCanisters();
      setBooks(data);
    };
    fetchData();
  }, []);
  let Cards = books.map((e, index) => {
    const uint8array = new Uint8Array(e.canisterMetaData.cover);
    const pdfUrl = URL.createObjectURL(
      new Blob([uint8array], { type: "image/jpeg" })
    );
    return (
      <div key={index} className="card bg-slate-200 rounded">
        <a href={`/booksection?id=${e.canisterID}`} className="block">
          <img
            alt=""
            src={pdfUrl}
            className="h-64 w-full object-cover sm:h-80 lg:h-96 rounded-t-lg"
          />

          <h3 className="mt-4 text-lg font-bold text-gray-900 sm:text-xl pl-4">
            {e.canisterMetaData.title}
          </h3>

          <p className="mt-2 max-w-sm text-gray-700 px-4 pb-4">
            {e.canisterMetaData.description}
          </p>
        </a>
      </div>
    );
  });

  return (
    <main className="container mx-auto my-6 min-h-[80vh]">
      <h1 className="ml-6 mb-5 font-bold text-2xl">Collections :</h1>
      <div className=" mx-6 grid grid-cols-260  gap-6 ">{Cards}</div>
    </main>
  );
}
