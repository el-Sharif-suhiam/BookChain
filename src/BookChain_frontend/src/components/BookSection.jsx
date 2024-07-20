import React from "react";
import { useParams } from "react-router-dom";
import { BookChain_backend } from "declarations/BookChain_backend";

export default function BookSection() {
  const queryString = window.location.search;
  const urlParams = new URLSearchParams(queryString);
  const canisterID = urlParams.get("id");
  const [book, setBook] = React.useState("");
  const [imageURl, setImageURL] = React.useState("");
  const [showData, setShowData] = React.useState(false);
  const [nftID, setnftID] = React.useState(0);
  console.log(canisterID);
  React.useEffect(() => {
    const fetchData = async () => {
      const data = await BookChain_backend.getBookMetadata(canisterID);
      const uint8array = new Uint8Array(data.cover);
      const pdfUrl = URL.createObjectURL(
        new Blob([uint8array], { type: "image/jpeg" })
      );
      setBook(data);
      setImageURL(pdfUrl);
      console.log(data);
    };
    fetchData();
    setShowData(!showData);
  }, []);

  return (
    <main className="flex flex-col mx-auto  max-w-screen-xl items-center gap-8 sm:px-6 lg:px-8 my-12 p-5 bg-slate-100 min-h-[80vh] ">
      {showData && (
        <div className="  md:flex md gap-8 justify-center items-center text-center">
          <img src={imageURl} className="w-[400px]"></img>
          <div className="my-3 flow-root rounded-lg border border-gray-100 py-3 shadow-sm h-full">
            <dl className="-my-3 divide-y divide-gray-100 text-sm ">
              <div className="grid grid-cols-1 gap-1 p-3 even:bg-gray-50 sm:grid-cols-3 sm:gap-4">
                <dt className="font-medium text-gray-900">Symbol</dt>
                <dd className="text-gray-700 sm:col-span-2">{book.symbol}</dd>
              </div>

              <div className="grid grid-cols-1 gap-1 p-3 even:bg-gray-50 sm:grid-cols-3 sm:gap-4">
                <dt className="font-medium text-gray-900">Title</dt>
                <dd className="text-gray-700 sm:col-span-2">{book.title}</dd>
              </div>

              <div className="grid grid-cols-1 gap-1 p-3 even:bg-gray-50 sm:grid-cols-3 sm:gap-4">
                <dt className="font-medium text-gray-900">publicationYear</dt>
                <dd className="text-gray-700 sm:col-span-2">
                  {book.publicationYear}
                </dd>
              </div>

              <div className="grid grid-cols-1 gap-1 p-3 even:bg-gray-50 sm:grid-cols-3 sm:gap-4">
                <dt className="font-medium text-gray-900">author</dt>
                <dd className="text-gray-700 sm:col-span-2">{book.author}</dd>
              </div>

              <div className="grid grid-cols-1 gap-1 p-3 even:bg-gray-50 sm:grid-cols-3 sm:gap-4">
                <dt className="font-medium text-gray-900">description</dt>
                <dd className="text-gray-700 sm:col-span-2">
                  {book.description}
                </dd>
              </div>
            </dl>
            <div className="mt-10 flex gap-2">
              <button
                className="bg-[#0d9488] text-white py-3 px-5 rounded-xl"
                onClick={() => {
                  async function mint() {
                    let minted = await BookChain_backend.mintBookNFT(
                      canisterID
                    );
                    console.log(Number(minted.ok));
                    setnftID(Number(minted.ok));
                  }
                  mint();
                }}
              >
                Mint Book copy
              </button>
              <a
                href={`/booksection/book?id=${canisterID}&NFTID=${nftID}`}
                className="bg-[#0d9488] text-white py-3 px-5 rounded-xl"
              >
                show NFT
              </a>
            </div>
          </div>
        </div>
      )}
    </main>
  );
}
