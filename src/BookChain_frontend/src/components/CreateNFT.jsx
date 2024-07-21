import React from "react";
import { identityContext } from "./_context/identitycontext";
import { BookChain_backend } from "declarations/BookChain_backend";
function CreateNFT() {
  let useIdentity = React.useContext(identityContext);

  const [bookMetaData, setBookMetaData] = React.useState({
    owner: useIdentity.userIdentity,
    title: "",
    author: "",
    description: "",
    cover: new Uint8Array(), // URL to the image
    symbol: "",
    publicationYear: "",
  });
  const [totalCap, setTotalCap] = React.useState(0);
  const [bookCanisterID, setBookCanisterID] = React.useState("");
  const [filePdf, setFilePdf] = React.useState("");

  ////////////////////////////////

  async function newHandleFile(bookCanisterID, file) {
    let blob = new Blob([file], { type: "application/pdf" });
    let promises = [];
    const chunkSize = 1800000;
    let partsNum = blob.size / chunkSize;
    console.log(partsNum);
    partsNum % 1 !== 0 ? (partsNum = Number(partsNum.toFixed(0))) : "";
    console.log(partsNum);
    let i = 0;
    for (let start = 0; start < blob.size; start += chunkSize) {
      const chunk = blob.slice(start, start + chunkSize);
      console.log(chunk);
      promises.push(
        await BookChain_backend.setBookFile(
          bookCanisterID,
          i,
          new Uint8Array(await chunk.arrayBuffer())
        )
      );
      console.log(i, chunk);
      i++;
      await Promise.all(promises).then((res) =>
        console.log("it's done : ", res)
      );
    }
  }
  // async function handleSubmit(event) {
  //   event.preventDefault();
  //   let actor = await BookChain_backend.MakeBook(bookMetaData, totalCap);
  //   // console.log(actor);
  //   // new Promise((resolve, reject) => {
  //   //   resolve(
  //   //     BookChain_backend.makeIc7(
  //   //       nftData.name,
  //   //       nftData.description,
  //   //       nftData.thumbnail
  //   //     )
  //   //   );
  //   // }).then((res) => {
  //   //   console.log(res);
  //   //   newHandleFile(res, filePdf);
  //   // });
  //   setBookCanisterID(actor);
  //   await newHandleFile(bookCanisterID, filePdf);
  // }

  ////////////////////////////
  ///////////////////////////////////////////////////////////
  /////// Reminder : work on the submit function
  /////////////////////////////////////////////////////////////
  async function handleSubmit(event) {
    event.preventDefault();
    if (useIdentity.userIdentity === "2vxsx-fae" || "") {
      console.log("use are not logged in");
    } else {
      console.log("welcome !!");
      setBookMetaData({ ...bookMetaData, owner: useIdentity.userIdentity });
      new Promise(async (resolve, reject) => {
        let cansiter = await BookChain_backend.MakeBook(
          bookMetaData,
          Number(totalCap)
        );
        setBookCanisterID(cansiter);
        resolve(cansiter);
      }).then((e) => {
        console.log(e);
        newHandleFile(e, filePdf);
      });
    }
  }
  ///////////////////////////////////////////////////////////////////
  return (
    <section className="w-full px-4 py-12 pb-4 sm:px-6 lg:px-8 bg-slate-200">
      <div className="mx-1 lg:mx-24 xl:w-[760px] xl:mx-auto my-8 py-3 relative text-center bg-white nft-create shadow-md rounded-lg px-3">
        <h2 className="mb-4 absolute">Bring Your Book to Life on BookChain!</h2>
        <p className="text-sm mt-6 px-5 text-slate-600">
          Provide your book's details to turn your PDF into a one-of-a-kind NFT.
          Experience the future of literature with BookChain and ensure your
          creative work is protected and celebrated. Begin the transformation
          today!
        </p>
        <form
          id="createNftForm"
          className="text-gray-500"
          onSubmit={handleSubmit}
        >
          <div className="grid md:grid-cols-2 gap-4 grid-cols-1">
            <div>
              <label htmlFor="bookTitle">Book Title:</label>
              <input
                value={bookMetaData.title}
                className="Nft-input"
                type="text"
                id="bookTitle"
                name="bookTitle"
                onChange={(e) => {
                  setBookMetaData({ ...bookMetaData, title: e.target.value });
                }}
                required
              />
            </div>
            <div>
              <label htmlFor="author">Author:</label>
              <input
                className="Nft-input"
                value={bookMetaData.author}
                type="text"
                id="author"
                name="author"
                onChange={(e) => {
                  setBookMetaData({ ...bookMetaData, author: e.target.value });
                }}
                required
              />
            </div>
          </div>

          <div>
            <label htmlFor="bookDescription">Book Description:</label>
            <textarea
              className="Nft-input"
              value={bookMetaData.description}
              id="bookDescription"
              name="bookDescription"
              rows="4"
              cols="50"
              onChange={(e) => {
                setBookMetaData({
                  ...bookMetaData,
                  description: e.target.value,
                });
              }}
              required
            ></textarea>
          </div>
          <div className="grid md:grid-cols-2 gap-4 grid-cols-1">
            <div>
              <label htmlFor="symbol">symbol:</label>
              <input
                className="Nft-input"
                value={bookMetaData.symbol}
                type="text"
                id="symbol"
                name="symbol"
                onChange={(e) => {
                  setBookMetaData({ ...bookMetaData, symbol: e.target.value });
                }}
              />
            </div>
            <div>
              <label htmlFor="total-cap">total cap:</label>
              <input
                className="Nft-input"
                value={totalCap}
                type="number"
                id="total-cap"
                name="total-cap"
                onChange={(e) => {
                  setTotalCap(e.target.value);
                }}
              />
            </div>
            <div>
              <label htmlFor="publicationYear">Publication Year:</label>
              <input
                className="Nft-input"
                value={bookMetaData.publicationYear}
                type="date"
                id="publicationYear"
                name="publicationYear"
                onChange={(e) => {
                  let pYear = e.target.value;
                  setBookMetaData({
                    ...bookMetaData,
                    publicationYear: pYear.toString(),
                  });
                }}
              />
            </div>
            <div>
              <label htmlFor="price">Price:</label>
              <input
                className="Nft-input"
                type="number"
                id="price"
                name="price"
                step="0.01"
                required
              />
            </div>
          </div>

          <div>
            <label htmlFor="bookFile">Upload Book File:</label>
            <input
              className="Nft-input"
              type="file"
              id="bookFile"
              name="bookFile"
              accept=".pdf"
              onChange={(e) => setFilePdf(e.target.files[0])}
              required
            />
          </div>
          <div>
            <label htmlFor="coverImage">Upload Cover Image:</label>
            <input
              className="Nft-input"
              type="file"
              id="coverImage"
              name="coverImage"
              accept="image/*"
              onChange={async (e) => {
                let file = e.target.files[0];
                let blob = new Blob([file], { type: "application/pdf" });
                let thefile = new Uint8Array(await blob.arrayBuffer());
                console.log(thefile);
                setBookMetaData({
                  ...bookMetaData,
                  cover: thefile,
                });
              }}
              required
            />
          </div>
          <button type="submit">Create NFT</button>
        </form>
      </div>
    </section>
  );
}

export default CreateNFT;
