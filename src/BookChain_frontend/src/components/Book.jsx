import React from "react";
import { BookChain_backend } from "declarations/BookChain_backend";
import { identityContext } from "./_context/identitycontext";

export default function Book() {
  let useIdentity = React.useContext(identityContext);
  const queryString = window.location.search;
  const urlParams = new URLSearchParams(queryString);
  const canisterID = urlParams.get("id");
  const NFTID = urlParams.get("NFTID");
  console.log(NFTID);
  const [filePdf, setFilePdf] = React.useState("");
  const [isShow, setIsShow] = React.useState(false);
  async function callChunks() {
    let fullFile = [];
    let array = [];

    // let fileSize = Number(await bookchain_backend.getFileSize());
    let fileSize = Number(await BookChain_backend.getBookSize(canisterID));

    console.log("file size is ", fileSize);
    const chunkSize = 1800000;
    let promises = [];
    for (let i = 0; i < fileSize; i++) {
      console.log(i);
      promises.push(
        await BookChain_backend.getBookFile(canisterID, i, Number(NFTID))
      );
      console.log(fullFile.length);
      await Promise.all(promises).then((res) => {
        console.log("it's done : ", res[i].ok);
        fullFile = array.concat(res[i].ok);
        array = fullFile;
        console.log(fullFile);
      });
    }

    console.log(fullFile.length);
    return fullFile;
  }

  async function handleShow() {
    let data = await callChunks();
    const pdfUrl = URL.createObjectURL(
      new Blob(data, { type: "application/pdf" })
    );
    console.log(pdfUrl);
    setIsShow(true);
    setFilePdf(pdfUrl);
  }
  React.useEffect(() => {}, []);
  return (
    <div className="flex flex-col justify-center items-center mx-auto  max-w-screen-xl i gap-8 sm:px-6 lg:px-8 my-12 p-5 bg-slate-100 h-[850px] w-[800px]">
      {isShow && <iframe height="800" width="800" src={filePdf} />}
      <button id="showBook" onClick={handleShow}>
        Show the book
      </button>
    </div>
  );
}
