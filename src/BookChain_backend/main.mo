import Types "types";
import Principal "mo:base/Principal";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Result "mo:base/Result";
import Cycles "mo:base/ExperimentalCycles";
import Array "mo:base/Array";
import Option "mo:base/Option";
import Time "mo:base/Time";
import Nat64 "mo:base/Nat64";
import Int64 "mo:base/Int64";
import Hash "mo:base/Hash";
import Nat "mo:base/Nat";
import Books "icrc7";

actor Main {
  type Result<ok, err> = Result.Result<ok, err>;
  //main canister database
  //let usersList = HashMap.HashMap<Principal, Types.UserInfo>(0, Principal.equal, Principal.hash);
  let usersList = HashMap.HashMap<Nat, Principal>(0, Nat.equal, Hash.hash);
  stable var booksCanistersList : Types.BooksCanisters = [];

  public shared ({ caller }) func registerUser(newUser : Text) : async Result<Nat, Text> {
    let userPrincipal = Principal.fromText(newUser);
    for (user in usersList.vals()) {
      if (user == userPrincipal) {
        return #err("you already been registered");
      };
    };
    let userNum = usersList.size();
    usersList.put(userNum, userPrincipal);
    return #ok(userNum);
  };
  // public shared ({ caller }) func registerUser(newUserInfo : Types.UserInfo) : async Result<(), Text> {
  //   switch (usersList.get(caller)) {
  //     case (null) { #ok(usersList.put(caller, newUserInfo)) };
  //     case (?user) #err("you already been registered");
  //   };
  // };

  // public shared ({ caller }) func updateUserInfo(newUserInfo : Types.UserInfo) : async Result<(), Text> {
  //   switch (usersList.get(caller)) {
  //     case (?user) { #ok(usersList.put(caller, newUserInfo)) };
  //     case (null) { #err("you are not register yet.") };
  //   };
  // };

  public query func getBookCanisters() : async Types.BooksCanisters {
    return booksCanistersList;
  };
  public query func getUsersTotalNum() : async Nat {
    return usersList.size();
  };

  // getting the main canister principal
  private func self() : async Principal {
    let self : Principal = Principal.fromActor(Main);
  };
  public func getMainCanisterPrincipal() : async Principal {
    return await self();
  };

  // Books canister functions

  public shared ({ caller }) func MakeBook(book : Types.BookRequest, total : Nat) : async Text {
    let bookData = {
      book with
      owner = caller;
    };
    var buffer : Buffer.Buffer<Types.Canister> = Buffer.fromArray(booksCanistersList);
    Cycles.add<system>(1_000_000_000_000);
    let bookCanister = await Books.Book(bookData, total); // accepts 10_000_000 cycles
    let principal = Principal.fromActor(bookCanister);
    let newBookCanisterId : Types.Canister = {
      canisterID = Principal.toText(principal);
      canisterMetaData = bookData;
    };
    buffer.add(newBookCanisterId);
    booksCanistersList := Buffer.toArray(buffer);
    return Principal.toText(principal);
  };

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////// calling the functions form the book canister /////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  /////////////////////////////////////////////////////////////////////////////////

  public func getActorOwner(id : Text) : async Principal {
    type CanisterInterface = actor {
      getOwner : () -> async Principal;
    };

    // Create a reference to the canister
    let canister = actor (id) : CanisterInterface;

    // Call the method on the canister
    await canister.getOwner();
  };

  public func getBookMetadata(id : Text) : async Types.Book_metadata {
    type CanisterInterface = actor {
      getBookMetadata : () -> async Types.Book_metadata;
    };
    let canister = actor (id) : CanisterInterface;
    await canister.getBookMetadata();
  };

  public shared ({ caller }) func setBookFile(id : Text, blobID : Nat, chunk : [Nat8]) : async Principal {
    type CanisterInterface = actor {
      setBookFile : (minter : Principal, blobID : Nat, data : [Nat8]) -> async ();
    };
    let canister = actor (id) : CanisterInterface;
    await canister.setBookFile(caller, blobID, chunk);
    return caller;
  };

  public func getBookSize(id : Text) : async Nat {
    type CanisterInterface = actor {
      getBookSize : () -> async Nat;
    };
    let canister = actor (id) : CanisterInterface;
    await canister.getBookSize();
  };

  public shared ({ caller }) func getBookFile(id : Text, index : Nat, nft_id : Types.NFT_ID) : async Result<Blob, Text> {
    type CanisterInterface = actor {
      getBookFile : (index : Nat, caller : Principal, nft_id : Types.NFT_ID) -> async Result<Blob, Text>;
    };
    let canister = actor (id) : CanisterInterface;
    await canister.getBookFile(index, caller, nft_id);
  };

  public func ownerOf(id : Text, nft_id : Types.NFT_ID) : async Result<Types.Account, Text> {
    type CanisterInterface = actor {
      icrc7_owner_of : (nft_id : Types.NFT_ID) -> async Result<Types.Account, Text>;
    };
    let canister = actor (id) : CanisterInterface;
    await canister.icrc7_owner_of(nft_id);
  };

  public func nftTransfer(id : Text, from : Principal, to : Principal, nft_id : Types.NFT_ID, memo : ?Blob) : async ?Types.TransferResult {
    let reciver : Types.Account = {
      owner = to;
      subaccount = ?Principal.toBlob(to);
    };
    let time = Time.now();
    let timeToNat64 : Nat64 = Int64.toNat64(Int64.fromInt(time));
    let args : Types.TransferArg = {
      from_subaccount = ?Principal.toBlob(from);
      to = reciver;
      token_id = nft_id;
      // type: leave open for now
      memo = memo;
      created_at_time = ?timeToNat64;
    };
    type CanisterInterface = actor {
      nftTransfer : (args : Types.TransferArg, from : Principal) -> async ?Types.TransferResult;
    };
    let canister = actor (id) : CanisterInterface;
    await canister.nftTransfer(args, from);
  };

  public func balanceOf(id : Text, accounts : Types.Account) : async Nat {
    type CanisterInterface = actor {
      icrc7_balance_of : (accounts : Types.Account) -> async Nat;
    };
    let canister = actor (id) : CanisterInterface;
    await canister.icrc7_balance_of(accounts);
  };

  public shared ({ caller }) func mintBookNFT(id : Text) : async Result<Nat, Text> {
    let creator : Types.Account = {
      owner = caller;
      subaccount = ?Principal.toBlob(caller);
    };
    let time = Time.now();
    let timeToNat64 : Nat64 = Int64.toNat64(Int64.fromInt(time));
    type CanisterInterface = actor {
      mintBookNFT : (creator : Types.Account, creationDate : Nat64) -> async Result<Nat, Text>;
    };
    let canister = actor (id) : CanisterInterface;
    await canister.mintBookNFT(creator, timeToNat64);
  };
};
