import { useState } from "react";
import { BookChain_backend } from "declarations/BookChain_backend";
import NavBar from "./components/Navbar";
import Footer from "./components/Footer";
import Home from "./components/Home";
import { Route, Routes, Link } from "react-router-dom";
import CreateNFT from "./components/CreateNFT";
import { AuthClient } from "@dfinity/auth-client";
import Collections from "./components/Collections";
import BookSection from "./components/BookSection";
import Book from "./components/Book";

function App() {
  return (
    <>
      <NavBar />
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/create" element={<CreateNFT />} />
        <Route path="/collections" element={<Collections />} />
        <Route path="/booksection" element={<BookSection />} />
        <Route path="/booksection/book" element={<Book />} />
        <Route path="*" element={<h1>error 404 page not found</h1>} />
      </Routes>
      {/* <main></main> */}
      <Footer />
    </>
  );
}

export default App;
