import Nat8 "mo:base/Nat8";
import Principal "mo:base/Principal";
module {
  public type Map = [(Text, Value)];
  public type Value = {
    #Int : Int;
    #Map : Map;
    #Nat : Nat;
    #Blob : Blob;
    #Text : Text;
    #Array : [Value];
  };
  public type NFT_ID = Nat;
  public type Account = {
    owner : Principal;
    subaccount : ?Blob;
  };
  public type TransferArg = {
    from_subaccount : ?Blob;
    to : Account;
    token_id : Nat;
    // type: leave open for now
    memo : ?Blob;
    created_at_time : ?Nat64;
  };

  public type Book_metadata = {
    owner : Principal;
    title : Text;
    author : Text;
    description : Text;
    cover : [Nat8]; // URL to the image
    symbol : Text;
    publicationYear : Text;
  };
  public type BookRequest = {
    owner : Text;
    title : Text;
    author : Text;
    description : Text;
    cover : [Nat8]; // URL to the image
    symbol : Text;
    publicationYear : Text;
  };
  public type Book_token = {
    symbol : Text;
    name : Text;
    total_supply : Nat;
  };
  public type NFTMetadata = {
    id : Nat;
    title : Text;
    description : Text;
    author : Text;
    owner : Account;
    creationDate : Nat64; // Timestamp of creation
  };
  public type UserInfo = {
    email : Text;
    userName : Text;
  };
  public type Canister = {
    canisterID : Text;
    canisterMetaData : Book_metadata;
  };
  public type BooksCanisters = [Canister];
  public type TransferResult = {
    #Ok : Nat;
    #Err : TransferError;
  };

  public type TransferError = {
    #NonExistingTokenId;
    #TooOld;
    #InvalidRecipient;
    #CreatedInFuture : { ledger_time : Nat64 };
    #Unauthorized;
    #Duplicate : { duplicate_of : Nat };
    #GenericError : {
      error_code : Nat;
      message : Text;
    };
    #GenericBatchError : { error_code : Nat; message : Text };
  };

};
