import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App";
import { BrowserRouter } from "react-router-dom";
import "./index.scss";
import IdentityProvider from "./components/IdentityProvider";

ReactDOM.createRoot(document.getElementById("root")).render(
  <React.StrictMode>
    <BrowserRouter>
      <IdentityProvider>
        <App />
      </IdentityProvider>
    </BrowserRouter>
  </React.StrictMode>
);
