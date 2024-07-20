import { createContext } from "react";
export let identityContext = createContext({
  userIdentity: "",
  setUserIdentity: null,
});
