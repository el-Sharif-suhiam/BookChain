import React from "react";
import { identityContext } from "./_context/identitycontext";

export default function Provider({ children }) {
  const [userIdentity, setUserIdentity] = React.useState("");
  const itemsData = {
    userIdentity: userIdentity,
    setUserIdentity,
  };
  return (
    <identityContext.Provider value={itemsData}>
      {children}
    </identityContext.Provider>
  );
}
