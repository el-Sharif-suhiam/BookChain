import Types "types";
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Nat "mo:base/Nat";
import Blob "mo:base/Blob";
import Result "mo:base/Result";
import Option "mo:base/Option";
import Bool "mo:base/Bool";
import Buffer "mo:base/Buffer";
shared (installer) actor class Book(book : Types.Book_metadata, total : Nat) = this {
  type Result<ok, err> = Result.Result<ok, err>;

  //basic data for the book NFT
  stable let creator : Principal = book.owner;
  stable var owner : Principal = book.owner;
  stable let book_metadata = book;
  let bookFile = HashMap.HashMap<Nat, Blob>(0, Nat.equal, Hash.hash);

  // Book Token Varibles

  stable let bookToken : Types.Book_token = {
    name = book.title;
    symbol = book.symbol;
    total_supply = total;
  };
  // BT stand for Book Token => fungible Token
  let btLedger = HashMap.HashMap<Principal, Nat>(0, Principal.equal, Principal.hash);
  // Book token Functions
  func mintBT() : () {
    btLedger.put(owner, bookToken.total_supply);
  };
  mintBT();
  // func checkTokenTotal() : Bool {
  //   var ledgerTotal = 0;
  //   for (token in btLedger.vals()) {
  //     ledgerTotal += token;
  //   };
  //   return ledgerTotal == bookToken.total_supply;
  // };

  public query func bookTokenMetadata() : async Types.Book_token {
    return bookToken;
  };

  // global functions

  public query func getOwner() : async Principal {
    return owner;
  };
  public query func getBookMetadata() : async Types.Book_metadata {
    return book_metadata;
  };

  public query func book_name() : async Text {
    return book_metadata.title;
  };
  public query func book_symbol() : async Text {
    return book_metadata.symbol;
  };
  public query func book_description() : async Text {
    return book_metadata.description;
  };
  public query func book_cover() : async [Nat8] {
    return book_metadata.cover;
  };
  public query func getTotalSupply() : async Nat {
    return bookToken.total_supply;
  };

  public shared ({ caller }) func mintBook(minter : Principal, blobID : Nat, data : [Nat8]) : async Result<(), Text> {
    assert Principal.isController(caller);
    if (minter == creator) {
      let dataChunk = Blob.fromArray(data);
      bookFile.put(blobID, dataChunk);
      #ok();
    } else {
      return #err("you are not the canister creator");
    };
  };

  public query func getBookSize() : async Nat {
    bookFile.size();
  };

  public query func getBookFile(index : Nat, caller : Principal) : async Result<Blob, Text> {
    let callerBalance = Option.get(btLedger.get(caller), 0);
    if (callerBalance >= 1) {
      switch (bookFile.get(index)) {
        case null #err("there no data file with this index => " # Nat.toText(index));
        case (?file) #ok(file);
      };
    } else {
      return #err("you don't have any " # bookToken.symbol # " token.");
    };
  };

  //to transfer the ownership for the original book
  public func bookTransfer(from : Principal, to : Principal) : async Text {
    if (Principal.equal(from, owner)) {
      owner := to;
      return "the new asset owner is : " # Principal.toText(owner);
    } else {
      return "you don't own this asset to transfer it.";
    };
  };

  public query func btBalanceOf(account : Principal) : async Nat {
    return Option.get(btLedger.get(account), 0);
  };

  public func btTransfer(from : Principal, to : Principal, amount : Nat) : async Text {
    let senderBalance : Nat = Option.get(btLedger.get(from), 0);
    let reciverBalance : Nat = Option.get(btLedger.get(to), 0);
    if (amount >= 1) {
      if (senderBalance >= amount) {
        let newSenderBalance = senderBalance - amount;
        let newReciverBalance = reciverBalance + amount;
        btLedger.put(from, newSenderBalance);
        btLedger.put(to, newReciverBalance);
        return "The transfer is done";
      } else {
        return "you don't have enough tokens to to finish the operation.";
      };
    } else {
      return "The transfer amount is insufficient, you should transfer 1 token or highr";
    };

  };

  public func isBtOnwer(account : Principal) : async Bool {
    let callerBalance : Nat = Option.get(btLedger.get(account), 0);
    if (callerBalance >= 1) {
      return true;
    } else { return false };
  };

  public func allBtOwners() : async [(Principal, Nat)] {
    var ownersBuffer = Buffer.Buffer<(Principal, Nat)>(0);
    for ((key, value) in btLedger.entries()) {
      ownersBuffer.add((key, value));
    };
    return Buffer.toArray(ownersBuffer);
  };
};
